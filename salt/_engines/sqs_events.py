# -*- coding: utf-8 -*-
'''
An engine that continuously reads messages from SQS and fires them as events.

Note that long polling is utilized to avoid excessive CPU usage.

.. versionadded:: 2015.8.0

:configuration:
    This engine can be run on the master or on a minion.

    Example Config:
        engines:
          - sqs_events:
             queue: test
             profile: my-sqs-profile #optional

    Explicit sqs credentials are accepted but this engine can also utilize
    IAM roles assigned to the instance through Instance Profiles. Dynamic
    credentials are then automatically obtained from AWS API and no further
    configuration is necessary. More Information available at::

       http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html

    If IAM roles are not used you need to specify them either in a pillar or
    in the config file of the master or minion, as appropriate::

        sqs.keyid: GKTADJGHEIQSXMKKRBJ08H
        sqs.key: askdjghsdfjkghWupUjasdflkdfklgjsdfjajkghs
        sqs.message_format: json

    A region may also be specified in the configuration::

        sqs.region: us-east-1

    If a region is not specified, the default is us-east-1.

    To deserialize the message from json:

        sqs.message_format: json

    It's also possible to specify key, keyid and region via a profile:

        myprofile:
            keyid: GKTADJGHEIQSXMKKRBJ08H
            key: askdjghsdfjkghWupUjasdflkdfklgjsdfjajkghs
            region: us-east-1

:depends: boto
'''

'''
Original source from:
    https://github.com/JensRantil/saltstack-autoscaling/blob/master/extensions/engines/sqs_events.py
'''

# Import python libs
from __future__ import absolute_import
import logging
import time
import json

# Import salt libs
import salt.utils.event

# Import third party libs
try:
    import boto.sqs
    HAS_BOTO = True
except ImportError:
    HAS_BOTO = False

try:
    # Python 3
    from urllib.request import urlopen
except ImportError:
    # Python 2
    from urllib2 import urlopen


from salt.ext.six import string_types


def __virtual__():
    if not HAS_BOTO:
        return (False, 'Cannot import engine sqs_events because the required boto module is missing')
    else:
        return True


log = logging.getLogger(__name__)


class RateLimiter:
    def __init__(self, min_interval):
        self._min_interval = min_interval
        self._last_acquire = None

    def acquire(self):
        if self._last_acquire is None:
            return
        diff_since_last_acquire = time.time() - self._last_acquire
        time.sleep(0 if diff_since_last_acquire > self._min_interval else self._min_interval - diff_since_last_acquire)
        self._last_acquire = time.time()


def _get_sqs_conn(profile, region=None, key=None, keyid=None):
    '''
    Get a boto connection to SQS.
    '''
    if profile:
        if isinstance(profile, string_types):
            _profile = __opts__[profile]
        elif isinstance(profile, dict):
            _profile = profile
        key = _profile.get('key', None)
        keyid = _profile.get('keyid', None)
        region = _profile.get('region', None)

    if not region:
        region = __opts__.get('sqs.region', 'us-east-1')
    if not key:
        key = __opts__.get('sqs.key', None)
    if not keyid:
        keyid = __opts__.get('sqs.keyid', None)

    extra_params = {}
    if not keyid and not key and map(int, boto.__version__.split('.')) <= [2,5,1]:
        # boto version >= 2.5.1 adds transparent support for this. This is a
        # workaround for older clients.

        roles = urlopen('http://169.254.169.254/latest/meta-data/iam/security-credentials/').read().splitlines()
        if roles:
            first_role = roles[0]
            role_data = json.load(urlopen('http://169.254.169.254/latest/meta-data/iam/security-credentials/' + first_role))
            keyid = role_data['AccessKeyId']
            key = role_data['SecretAccessKey']

            # TODO: A security token has an expiration date. Currently, this
            # will lead to SQS sporadically failing. Retry logic is in place
            # after 10 seconds which should get an updated token.
            extra_params['security_token'] = role_data['Token']

    try:
        conn = boto.sqs.connect_to_region(region, aws_access_key_id=keyid,
                                          aws_secret_access_key=key, **extra_params)
    except boto.exception.NoAuthHandlerFound:
        log.error('No authentication credentials found when attempting to'
                  ' make sqs_event engine connection to AWS.')
        return None
    return conn


def start(queue, profile=None, tag='salt/engine/sqs'):
    '''
    Listen to events and write them to a log file
    '''
    if __opts__.get('__role') == 'master':
        fire_master = salt.utils.event.get_master_event(
            __opts__,
            __opts__['sock_dir'],
            listen=False).fire_event
    else:
        fire_master = None

    message_format = __opts__.get('sqs.message_format', None)

    def fire(tag, msg):
        if fire_master:
            fire_master(msg, tag)
        else:
            __salt__['event.send'](tag, msg)

    sqs = _get_sqs_conn(profile)
    q = sqs.get_queue(queue)
    q.set_message_class(boto.sqs.message.RawMessage)

    rate_limiter = RateLimiter(5)
    while True:
        if not q:
            log.warning('failure connecting to queue: {0}, '
                        'waiting 10 seconds.'.format(queue))
            time.sleep(10)
            q = sqs.get_queue(queue)
            if not q:
                continue

        try:
            msgs = q.get_messages(wait_time_seconds=20)
        except TypeError:
            # Older versions of boto (such as 2.2.2 included with Ubuntu 12.04)
            # doesn't support long polling. Notice that the `rate_limiter` we don't start pounding AWS.
            msgs = q.get_messages()
        for msg in msgs:
            if message_format == "json":
                sqsmessage = json.loads(msg.get_body())
                try:
                    sqsmessage['Message'] = json.loads(sqsmessage['Message'])
                except ValueError:
                    pass
                fire(tag, {'message': sqsmessage})
            else:
                fire(tag, {'message': msg.get_body()})
            msg.delete()
        else:
            rate_limiter.acquire()
