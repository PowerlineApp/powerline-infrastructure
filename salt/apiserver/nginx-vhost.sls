# Pillar
{% set project = salt['pillar.get']('civix:project') %}
{% set user = salt['pillar.get']('civix:user') %}
{% set domain = salt['pillar.get']('civix:domain') %}

# Grains
{% set env = salt['grains.get']('civix:environment') %}
{% set hostname = salt['grains.get']('hostname') %}

# get public ipv4 address. should figure out the better way via ec2
{% set addr = salt['network.interface_ip']('eth0') %}
{% set host = salt['network.get_hostname']() %}

{% if env.startswith("prod") -%}
    {% set api = "api-prod" -%}
{% elif env.startswith("staging") -%}
    {% set api = "api-staging" -%}
{% elif env.startswith("dev") -%}
    {% set api = "api-dev" -%}
{% else -%}
    {% set api = "" -%}
{% endif -%}


include:
  - nginx

config-apiserver-vhost:
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
        api: {{ api }}
        host: {{ host }}
        addr: {{ addr }}
        root_dir: /srv/civix/apiserver
        log_dir: /srv/log
        certs_dir: /srv/certs
    - require:
      - sls: nginx

enable-site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ project }}
    - target: /etc/nginx/sites-available/{{ project }}
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - file: config-apiserver-vhost

