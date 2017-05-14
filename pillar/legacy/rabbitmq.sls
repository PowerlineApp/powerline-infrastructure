rabbitmq:
  version: 3.2.4-1
  enabled: True
  running: True
  plugin:
    rabbitmq_management:
      - enabled
  vhost:
    vh_name: 'civix'
  user:
    civix:
      - password: civix
      - force: True
      - perms:
        - 'civix':
          - '.*'
          - '.*'
          - '.*'
      - runas: root
