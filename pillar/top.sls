dev:
  'butler-api-*':
    - salt.minion
    - nginx
    - node
  'butler-db-*':
    - salt.minion
    - mongodb
