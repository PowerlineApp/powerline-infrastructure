{% set user = salt['pillar.get']('civix:user') -%}
{% set php_ver = salt['pillar.get']('civix:php:version') -%}

common-php-ppa:
  pkgrepo.managed:
    - ppa: {{ salt['pillar.get']('civix:php:ppa') }}
    - refresh_db: True

common-php-pkgs:
  pkg.installed:
    - pkgs:
      - php{{php_ver}}
      - php{{php_ver}}-common
      - php{{php_ver}}-cli
    - skip_verify: True
    - require:
      - pkgrepo: common-php-ppa

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
    - user: {{ user }}
    - group: {{ user }}
    - dir_mode: 755

install-deps:
  pkg.installed:
    - pkgs:
      - curl
      - git

# install-gitpython:
#   pip.installed:
#     - name: gitpython

# install-boto3:
#   pip.installed:
#     - name: boto3
