{% set user = salt['pillar.get']('civix:user') %}
{% set repo = salt['pillar.get']('civix:deploy:repo') %}
{% set php_ver = salt['pillar.get']('civix:php:version') %}

{% set build_repo = 'https://s3.amazonaws.com/powerline-apiserver-builds' %}
{% set build = salt['pillar.get']('build', 'latest')%}

{% set env = {
  'production'  : 'prod',
  'development' : 'dev',
  'staging'     : 'prod'}.get(salt['grains.get']('civix:environment')) %}

{% set branch = {
  'prod'     : 'release',
  'staging'  : 'master',
  'dev'      : 'develop'}.get( env ) %}

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

# =========================
# ====== STOP SERVICES ====
# =========================
stop-nginx-for-deploy:
  service.dead:
    - name: nginx
    - onchanges:
      - file: pull-deb

stop-fpm-for-deploy:
  service.dead:
    - name: php{{php_ver}}-fpm
    - onchanges:
      - file: pull-deb

# ===========================
# ====== Install latest =====
# ===========================

install-civix-build:
  pkg.installed:
    - sources:
      - civix-apiserver: /srv/civix-apiserver_{{ build }}_all.deb
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

change-owner:
  file.directory:
    - name: /srv/civix/apiserver
    - user: {{ user }}
    - group: {{ user }}
    - recurse:
      - user
      - group

# fix the console perms
console-perms:
  file.managed:
    - name: /srv/civix/apiserver/bin/console
    - mode: 755
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - pkg: install-civix-build
      - file: link-in-new-build

# =========================
# ==== RESTART SERVICES ===
# =========================

restart-nginx-for-deploy:
  service.running:
    - name: nginx

restart-fpm-for-deploy:
  service.running:
    - name: php{{php_ver}}-fpm

# =========================
# ====== POST DEPLOY ======
# =========================

# Warm cache
warm-cache:
  cmd.run:
    - name: /srv/civix/apiserver/bin/console cache:warmup --env={{ env }}
    - runas: {{ user }}
    - require:
      - pkg: install-civix-build

# Run migrations
doctrine-migrations:
  cmd.run:
    - name: /srv/civix/apiserver/bin/console doctrine:migrations:migrate -n
    - runas: {{ user }}
    - require:
      - pkg: install-civix-build

bounce-supervisor-push-queue:
  supervisord.running:
    - name: civix_push_queue
    - restart: True

bounce-supervisor-payments:
  supervisord.running:
    - name: civix_payments
    - restart: True

# Add a release grain to the minion
app-build-version:
  grains.present:
    - name: civix:build
    - value: {{ build }}

