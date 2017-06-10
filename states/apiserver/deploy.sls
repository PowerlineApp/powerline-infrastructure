{% set user = salt['pillar.get']('civix:user') %}
{% set repo = salt['pillar.get']('civix:deploy:repo') %}
{% set php_ver = salt['pillar.get']('civix:php:version') %}

{% set build_repo = 'https://s3.amazonaws.com/powerline-apiserver-builds' %}
{% set build = salt['pillar.get']('build')%}

{% set env = {
  'production'  : 'prod',
  'development' : 'dev',
  'staging'     : 'prod'}.get(salt['grains.get']('civix:environment')) %}

{% set branch = {
  'prod'     : 'releases',
  'staging'  : 'master',
  'dev'      : 'develop'}.get(salt['grains.get']('civix:env')) %}

# =========================
# ====== get build ========
# =========================

# Get the latest build of powerline-server from s3
pull-deb:
  file.managed:
    - name: /srv/civix-apiserver_{{ build }}_all.deb
    - user: {{ user }}
    - group: {{ user }}
    - source: {{ build_repo }}/{{ branch }}/civix-apiserver_{{ build }}_all.deb
    - source_hash: {{ build_repo }}/{{ branch }}/civix-apiserver_{{ build }}_all.deb.hash
    - order: 1
    - failhard: True

# =============================
# ====== get parameters =======
# =============================

# This will pull in all parameters defined in the
# pillar for whatever env you are working on
# The env is defined by the grains of the instance
get-parameters:
  file.serialize:
    - name: /srv/config/parameters.yml
    - mode: 644
    - user: {{ user }}
    - group: {{ user }}
    - dataset_pillar: civix:symfony
    - formatter: yaml
    - failhard: True
    - require:
      - file: pull-deb

# =========================
# ====== STOP SERVICES ====
# =========================
#stop-nginx-for-deploy:
#  service.dead:
#    - name: nginx
#    - onchanges:
#      - file: pull-deb

#stop-fpm-for-deploy:
#  service.dead:
#    - name: php{{php_ver}}-fpm
#    - onchanges:
#      - file: pull-deb

# ===========================
# ====== Install latest =====
# ===========================

install-civix-build:
  pkg.installed:
    - sources:
      - civix-apiserver: /srv/civix-apiserver_{{ build }}_all.deb
    - failhard: True
    - require:
      - file: pull-deb

link-in-new-build:
  file.symlink:
    - name: /srv/civix/apiserver
    - target: /srv/civix-apiserver/{{ build }}
    - require:
      - pkg: install-civix-build

link-in-parameters:
  file.symlink:
    - name: /srv/civix/apiserver/app/config/parameters.yml
    - target: /srv/config/parameters.yml
    - force: True
    - require:
      - file: link-in-new-build

change-build-dir-owner:
  file.directory:
    - name: /srv/civix-apiserver/{{ build }}
    - user: {{ user }}
    - group: {{ user }}
    - recurse:
      - user
      - group
    - require:
      - pkg: install-civix-build

# fix the console perms
console-perms:
  file.managed:
    - name: /srv/civix/apiserver/bin/console
    - mode: 755
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - file: link-in-new-build

# Using cmd.run to run composer because the module never
# seemed to pass correctly because of stderr that wasn't really
# a problem
{% set composer_opts = '' %}
{% if env == 'prod' %}
{%  set composer_opts = '--no-dev --optimize-autoloader' %}
{% endif %}
run-composer:
  cmd.run:
    - name: /usr/local/bin/composer -q install {{ composer_opts }}
    - cwd: /srv/civix/apiserver
    - runas: civix
    - require:
      - file: link-in-new-build

# =========================
# ==== RESTART SERVICES ===
# =========================

# NOTE: Using watch so that the services
#       will restart in specific order

restart-nginx-for-deploy:
  service.running:
    - name: nginx
    - watch:
      - cmd: run-composer

restart-fpm-for-deploy:
  service.running:
    - name: php{{php_ver}}-fpm
    - watch:
      - cmd: run-composer

# =========================
# ====== POST DEPLOY ======
# =========================

# Warm cache
warm-cache:
  cmd.run:
    - name: /srv/civix/apiserver/bin/console cache:warmup --env={{ env }}
    - runas: {{ user }}
    - require:
      - file: link-in-new-build

# Run migrations
doctrine-migrations:
  cmd.run:
    - name: /srv/civix/apiserver/bin/console doctrine:migrations:migrate -n
    - runas: {{ user }}
    - require:
      - file: link-in-new-build

# ===== bounce queues =====

bounce-supervisor-push-queue:
  supervisord.running:
    - name: civix_push_queue
    - restart: True
    - watch:
      - service: restart-nginx-for-deploy

bounce-supervisor-payments:
  supervisord.running:
    - name: civix_payments
    - restart: True
    - watch:
      - service: restart-nginx-for-deploy

# Add a release grain to the minion
app-build-version:
  grains.present:
    - name: civix:build
    - value: {{ build }}
    - require:
      - file: link-in-new-build
