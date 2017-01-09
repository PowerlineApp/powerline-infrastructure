
install-php-pkgs:
  pkgrepo.managed:
    - ppa: ondrej/php5-oldstable
  pkg.installed:
    - pkgs:
      - php5
      - php5-common
      - php5-cli
      - php5-curl
      - php5-gd
      - php5-mysql
      - php5-sqlite
      - php5-intl

