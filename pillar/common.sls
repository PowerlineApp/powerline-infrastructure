civix:
  project: civix
  user: civix
  deployment-bucket: deployment-data
  php:
    ppa: ondrej/php
  deploy:
    absent_files:
      - app/cache
      - app/logs
      - src/Civix/ApiBundle/Tests
      - src/Civix/CoreBundle/Tests
      - src/Civix/CoreBundle/Test
      - web/app_test.php
      - app/phpunit.xml.dist
      - app/config/parameters.default.yml
      - app/config/parameters.travis.yml
      - app/config/parameters.vagrant.yml
    build_files:
      - app
      - src
      - web
      - composer.lock
      - composer.json
    repo: https://github.com/PowerlineApp/powerline-server.git
  supervisord:
    queues:
      - push_queue
      - payments
      - subscriptions
  rabbitmq:
    user: civix
    vhost: civix
