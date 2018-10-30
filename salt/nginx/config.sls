{% set project = salt['pillar.get']('civix:project') %}
{% set user = salt['pillar.get']('civix:user') %}

# Remove the default site
remove-default-site:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

nginx-conf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - context:
        user: {{ project }}

restart-nginx-for-configs:
  service.running:
    - name: nginx
    - onchanges:
      - file: nginx-conf
