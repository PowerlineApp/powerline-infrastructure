
base:
  '*':
    - ntp
    - cron
    - common
  'civix:roles:apiserver':
    - match: grain
    - apiserver
