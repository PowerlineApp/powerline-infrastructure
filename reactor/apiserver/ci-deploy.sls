# Reactor for travis webhooks.
#
# This will kickoff the orchestration runner to handle deployment
# of apiserver code to the right environment based on the branch.
#
# The `data` obj should have a `post` attribute that lays out the
# details needed from travis.
#
# To run a test:
# salt-run event.send salt/netapi/hook/build/success '{"post":{ "payload":"{\"branch\":\"develop\",\"number\":135}"}}'

{% set payload = data.get('post', {}).get('payload',{})|load_json %}

# kickoff api orch runner
orchestrate-ci-deploy:
  runner.state.orchestrate:
    - mods: apiserver.orch-deploy
    - pillar:
        build_branch: {{ payload['branch'] }}
        build_number: {{ payload['number'] }}
