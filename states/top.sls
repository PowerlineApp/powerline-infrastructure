
base:
  '*':
    - ntp
    - cron
  'civix:roles:apiserver':
    - match: grain
    - common
    - apiserver
