{% set project = salt['pillar.get']('civix:project') %}
{% set user = salt['pillar.get']('civix:user') %}
{% set certs_dir = salt['pillar.get']('civix:certs_dir') %}

nginx-deploy-server-key:
  file.managed:
    - name: {{certs_dir}}/{{ project }}-server.key
    - source: salt://{{ env }}/certs/server.key
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - listen:
      - service: restart-nginx

nginx-deploy-server-crt:
  file.managed:
    - name: {{certs_dir}}/{{ project }}-server.crt
    - source: salt://{{ env }}/certs/server.crt
    - user: {{ user }}
    - group: {{ user }}
    - mode: 644
    - listen:
      - service: restart-nginx

# Using listen to trigger a restart if and only if the config
# runs were successful AND with changes. Since both would change
# listen should punt to the end of the run for the restart
restart-nginx:
  service.running:
    - name: nginx
