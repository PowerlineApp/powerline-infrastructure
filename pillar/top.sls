base:
  '*':
    - common
  'civix:environment:vagrant':
    - match: grain
    - apiserver.vagrant
    - apiserver.vagrant.parameters
    - apiserver.vagrant.private
  'civix:environment:development':
    - match: grain
    - apiserver.development
  'civix:environment:staging':
    - match: grain
    - apiserver.staging
  'civix:environment:production':
    - match: grain
    - apiserver.production
