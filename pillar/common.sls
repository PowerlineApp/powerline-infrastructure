salt_version: '2016.11.5'
civix:
  project: civix
  user: civix
  domain: powerlinegroups.com
  deployment-bucket: deployment-data
  php:
    ppa: ondrej/php
  deploy:
    repo: https://github.com/PowerlineApp/powerline-server.git
  rabbitmq:
    user: civix
    vhost: civix
  asg:
    prefix: pas
