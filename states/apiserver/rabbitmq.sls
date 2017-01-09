{% set rabbitmq_pass = salt['pillar.get']('civix:rabbitmq:passwd') %}
{% set rabbitmq_user = salt['pillar.get']('civix:rabbitmq:user') %}
{% set rabbitmq_vhost = salt['pillar.get']('civix:rabbitmq:vhost') %}

install-rabbitmq:
  pkg.installed:
    - name: rabbitmq-server

manage-rabbitmq:
  service.running:
    - name: rabbitmq-server
    - reload: True
    - enable: True
    - watch:
      - pkg: rabbitmq-server

symlink-server:
  file.symlink:
    - name: /usr/bin/rabbitmqctl
    - target: /usr/sbin/rabbitmqctl

# # Installed the rabbitmq mgmt console
# install_rabbit_management:
#   cmd.run:
#     - name : curl -k -L http://localhost:15672/cli/rabbitmqadmin -o /usr/local/sbin/rabbitmqadmin

# chmod_rabbit_management:
#   file.managed:
#   - name: /usr/local/sbin/rabbitmqadmin
#   - user: root
#   - group: root
#   - mode: 755
#   - require:
#     - cmd : install_rabbit_management

rabbitmq_vhost_{{ rabbitmq_vhost }}:
  rabbitmq_vhost.present:
    - name: {{ rabbitmq_vhost }}
    - require:
      - service: rabbitmq-server

rabbitmq_user_{{ rabbitmq_user }}:
  rabbitmq_user.present:
    - name: {{ rabbitmq_user }}
    - perms:
      - {{ rabbitmq_vhost }}:
        - '.*'
        - '.*'
        - '.*'
    - password: {{ rabbitmq_pass }}
    - require:
      - service: rabbitmq-server
