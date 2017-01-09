
include:
  - .php
  - .fpm
  - .nginx
  - .supervisor
  - .rabbitmq
{% if salt['grains.get']('civix:environment') == 'vagrant' %}
  - .mysql
{% endif %}
