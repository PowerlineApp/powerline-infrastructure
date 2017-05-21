base:
  '*':
    - common
    - parameters

  'civix:environment:vagrant':
    - match: grain
    - apiserver.vagrant
    - apiserver.vagrant.parameters

  'civix:environment:development':
    - match: grain
    - apiserver.development
    - apiserver.development.parameters

  'civix:environment:staging':
    - match: grain
    - apiserver.staging
    - apiserver.staging.parameters

  'civix:environment:production':
    - match: grain
    - apiserver.production
    - apiserver.production.parameters

# === Legacy section ====
# this will use /srv/powerline-legacy/salt

  'civix-dev':
    - legacy.rabbitmq
