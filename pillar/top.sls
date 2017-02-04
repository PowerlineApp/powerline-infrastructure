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
  'civix:environment:production':
    - match: grain
    - apiserver.production
