base:
  '*'
    - salt.minion
dev:
  'butler-api-*':
    - nginx
    - node
  'butler-db-*':
    - mongodb
