{% set asg_prefix = salt['pillar.get']('civix:asg:prefix') %}
{% if data['act']=='pend' and data['id'].startswith(asg_prefix) %}
register_minion_if_autoscaling_instance:
  runner.autoscaling.minion_connected:
    - name: {{ data['id'] }}
{% endif %}
