{% set user = salt['pillar.get']('civix:user') %}
{% set ppa = salt['pillar.get']('civix:ppa') %}

common-php-pkgs:
  pkgrepo.managed:
    - ppa: {{ ppa }}
  pkg.installed:
    - pkgs:
    {% for pkg in salt['pillar.get']('civix:php_pkgs') -%}
      - {{ pkg }}
    {% endfor %}

add-civix-user:
  user.present:
    - name: {{ user }}
    - fullname: {{ user }}
    - home: /srv/{{ user }}

config-dirs:
  file.directory:
    - names:
      - /srv/log
      - /srv/civix
      - /srv/config
      - /srv/certs
      - /srv/powerline-server-releases
      - /srv/powerline-server
    - user: {{ user }}
    - group: {{ user }}
    - dir_mode: 755

get-composer:
  cmd.run:
    - name: 'CURL=`which curl`; $CURL -sS https://getcomposer.org/installer | php'
    - unless: test -f /usr/local/bin/composer
    - cwd: /root/
    - env:
      - HOME: /root

install-composer:
  cmd.run:
    - name: mv /root/composer.phar /usr/local/bin/composer
    - cwd: /root/
    - onchanges:
      - cmd: get-composer

install-curl:
  pkg.installed:
    - pkgs:
      - curl
      - python-pip
      - git

install-python-utils:
  pip.installed:
    - pkgs:
      - gitpython
      - boto3
