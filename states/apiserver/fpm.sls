{% set project = salt['pillar.get']('civix:project', 'civix') %}
{% set user = salt['pillar.get']('civix:user', '') %}

install-fpm:
  pkg.installed:
    - name: php5-fpm

config-civix-pool:
  file.managed:
    - name: /etc/php5/fpm/pool.d/{{ project }}.conf
    - source: salt://apiserver/files/fpm.conf
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - context:
        project: {{ project }}

remove-www-pool:
  file.absent:
    - name: /etc/php5/fpm/pool.d/www.conf

manage-fpm:
  service.running:
    - name: php5-fpm
    - enable: True
    - reload: True
    - watch:
      - file: config-civix-pool
      - file: remove-www-pool
