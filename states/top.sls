
base:
  '*':
    - ntp
    - cron
  'civix:roles:apiserver':
    - match: grain
    - common
    - apiserver

# === Legacy section ====
# this will use /srv/powerline-legacy/salt

  'civix-dev':
    - legacy.rabbitmq
