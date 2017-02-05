{% set project = salt['pillar.get']('civix:project') %}
{% set user = salt['pillar.get']('civix:user') %}

{% set env = salt['grains.get']('civix:environment') %}
{% set hostname = salt['grains.get']('hostname') %}

install-nginx:
  pkg.installed:
    - name: nginx

config-nginx-conf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://apiserver/files/nginx.conf
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - context:
        user: {{ project }}

config-vhost:
  file.managed:
    - name: /etc/nginx/sites-available/{{ project }}
    - source: salt://apiserver/files/vhost.conf
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - context:
        project: {{ project }}
        server_name: {{ hostname }}

# If the env is vagrant, we are building/testing on vagrant. Therefore
# we pull in the self signed certs that aren't related to powerline
# domain.
{% if env == 'vagrant' %}

  {% for cert in ["server.key", "server.crt"] %}
get-vagrant-deploy-{{ cert }}:
  file.copy:
    - name: /srv/certs/{{ project }}-{{ cert }}
    - source: /vagrant/dev/certs/{{ cert }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
  {% endfor %}

{% else %}

  {% for cert, hash in salt['pillar.get']('civix:api_certs').items() %}
get-deploy-{{ cert }}:
  file.managed:
    - name: /srv/certs/{{ project }}-{{ cert }}
    - source: s3://{{ salt['pillar.get']('civix:deployment-bucket') }}/{{ env }}/certs/{{ cert }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - source_hash: md5={{ hash }}
  {% endfor %}

{% endif %}

remove-default-site:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

enable-site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ project }}
    - target: /etc/nginx/sites-available/{{ project }}
    - user: {{ user }}
    - group: {{ user }}

manage-nginx:
  service.running:
    - name: nginx

# Restart nginx if changes
restart-nginx:
  service.running:
    - name: nginx
    - onchanges:
      - file: enable-site
      - file: config-vhost
      - file: config-nginx-conf
