# If needed, we can drive nginx config through pillar data.
# We just need to add the nginx pillar when that is needed.
# For now, a generic nginx.conf is good.

{% if grains['os'] == 'Ubuntu' %}
stop-apache2:
  service.dead:
    - name: apache2
{% endif %}

nginx-install:
  pkg.installed:
    - name: nginx

manage-nginx:
  service.running:
    - name: nginx
    - enable: True
