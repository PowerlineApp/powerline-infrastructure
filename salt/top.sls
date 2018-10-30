
base:
  '*':
    - ntp
    - cron
  'salt-master':
    - salt.master
  'butler-*':
    - salt-minion
dev:
  'butler-api-*':
    - nginx.ng
    - node
  'butler-db-*':
    - mongo
