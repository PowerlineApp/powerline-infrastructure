civix:
  php:
    version: '7.0'
    packages:
      - php7.0
      - php7.0-common
      - php7.0-cli
  deploy:
    rev: develop
  environment: development
  api_certs:
    server.crt: 87833921427210fbe25280c7854eb489
    server.key: 222595d86aa79ec1edff5221eb58fe7c
