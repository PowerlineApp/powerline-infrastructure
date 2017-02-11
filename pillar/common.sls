civix:
  project: civix
  user: civix
  deployment-bucket: deployment-data
  php:
    ppa: ondrej/php
  deploy:
    repo: https://github.com/PowerlineApp/powerline-server.git
  supervisord:
    queues:
      - push_queue
      - payments
      - subscriptions
  rabbitmq:
    user: civix
    vhost: civix
