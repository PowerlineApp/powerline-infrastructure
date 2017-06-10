{% set project = salt['pillar.get']('civix:project') %}
{% set user = salt['pillar.get']('civix:user') %}
{% set certs_dir = salt['pillar.get']('civix:certs_dir') %}
{% set env = salt['pillar.get']('civix:environment') %}

# This certs should be picked up from s3 ext pillar
nginx-deploy-server-key:
  file.managed:
    - name: {{certs_dir}}/{{ project }}-server.key
    - source: salt://{{ env }}/certs/apiserver.key
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - listen:
      - service: restart-nginx-for-certs

nginx-deploy-server-crt:
  file.managed:
    - name: {{certs_dir}}/{{ project }}-server.crt
    - source: salt://{{ env }}/certs/apiserver.crt
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - listen:
      - service: restart-nginx-for-certs

# Using listen to trigger a restart if and only if the config
# runs were successful AND with changes. Since both would change
# listen should punt to the end of the run for the restart
restart-nginx-for-certs:
  service.running:
    - name: nginx
