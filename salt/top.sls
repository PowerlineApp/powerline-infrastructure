base:
  'salt-master':
    - salt.master
  'butler-api-*':
    - salt.minion
    - nginx.ng
    - node
  'butler-db-*':
    - salt.minion
    - mongo
