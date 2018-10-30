
include:
  - .php
  - .fpm
  - .nginx-vhost
  - .supervisor
  - .rabbitmq
{% if salt['grains.get']('civix:environment') == 'vagrant' %}
  - .mysql
{% endif %}
