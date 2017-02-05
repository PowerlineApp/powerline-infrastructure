{% set project = salt['pillar.get']('civix:project', 'civix') %}
{% set user = salt['pillar.get']('civix:user', '') %}
{% set php_ver = salt['pillar.get']('civix:php:version') %}

install-fpm:
  pkg.installed:
    - name: php{{php_ver}}-fpm

config-civix-pool:
  file.managed:
    - name: /etc/php/{{php_ver}}/fpm/pool.d/{{ project }}.conf
    - source: salt://apiserver/files/fpm.conf
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - context:
        project: {{ project }}

remove-www-pool:
  file.absent:
    - name: /etc/php/{{php_ver}}/fpm/pool.d/www.conf

manage-fpm:
  service.running:
    - name: php{{php_ver}}-fpm
    - enable: True
    - reload: True
    - watch:
      - file: config-civix-pool
      - file: remove-www-pool
