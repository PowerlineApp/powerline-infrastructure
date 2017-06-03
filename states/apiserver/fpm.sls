
# NOTE:
#   The immeidate issue with FPM is that the init scripts run it as
#   the version that is installed (php<ver>-fpm). so stopping to load
#   a new version is not going to work here. you need to manually stop
#   the previous one and start the new one.

{% set project = salt['pillar.get']('civix:project', 'civix') %}
{% set user = salt['pillar.get']('civix:user', '') %}
{% set php_ver = salt['pillar.get']('civix:php:version') %}

install-fpm:
  pkg.installed:
    - name: php{{php_ver}}-fpm
    - skip_verify: True

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

restart-fpm-configs:
  service.running:
    - name: php{{php_ver}}-fpm
    - listen:
      - file: config-civix-pool

remove-www-pool:
  file.absent:
    - name: /etc/php/{{php_ver}}/fpm/pool.d/www.conf

restart-fpm-configs:
  service.running:
    - name: php{{php_ver}}-fpm
    - listen:
      - file: remove-www-pool

manage-fpm:
  service.running:
    - name: php{{php_ver}}-fpm
    - enable: True


