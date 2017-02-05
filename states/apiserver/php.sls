
install-php-pkgs:
  pkgrepo.managed:
    - ppa: ondrej/php
  pkg.installed:
    - pkgs:
      - php5.6
      - php5.6-common
      - php5.6-cli
      - php5.6-curl
      - php5.6-gd
      - php5.6-mysql
      - php5.6-sqlite3
      - php5.6-intl
