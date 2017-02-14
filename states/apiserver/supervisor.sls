{% set project = salt['pillar.get']('civix:project') %}
{% set user = salt['pillar.get']('civix:user') %}
{% set env = {
  'production'  : 'prod',
  'development' : 'dev',
  'staging'     : 'prod'}.get(salt['pillar.get']('civix:environment')) %}

install-supervisor:
  pkg.installed:
    - name: supervisor

manage-supervisor:
  service.running:
    - name: supervisor
    - enable: True
    - watch:
      - pkg: supervisor

config-push-queue:
  file.managed:
    - name: /etc/supervisor/conf.d/{{ project }}_push_queue.conf
    - source: salt://apiserver/files/supervisor_push_queue.conf
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - context:
        project: {{ project }}
        env : {{ env }}

config-payments:
  file.managed:
    - name: /etc/supervisor/conf.d/{{ project }}_payments.conf
    - source: salt://apiserver/files/supervisor_payments.conf
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - context:
        project: {{ project }}
        env : {{ env }}


config-subscriptions:
  file.managed:
    - name: /etc/supervisor/conf.d/{{ project }}_subscriptions.conf
    - source: salt://apiserver/files/supervisor_subscriptions.conf
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - context:
        project: {{ project }}
        env : {{ env }}


{% for q in salt['pillar.get']('civix:supervisord:queues') %}
supervisor-service-{{ q }}:
  supervisord.running:
    - name: {{ project }}_{{ q }}
    - onchanges:
      - file: /etc/supervisor/conf.d/{{ project }}_{{ q }}.conf
{% endfor %}
