{% set user = salt['pillar.get']('civix:user') %}
{% set repo = salt['pillar.get']('civix:deploy:repo') %}
{% set php_ver = salt['pillar.get']('civix:php:version') %}

{% set build_repo = 'https://s3.amazonaws.com/powerline-apiserver-builds' %}
{% set build = salt['pillar.get']('build', 'latest')%}

{% set env = {
  'production'  : 'prod',
  'development' : 'dev',
  'staging'     : 'prod'}.get(salt['pillar.get']('civix:environment')) %}

# =========================
# ====== get build ========
# =========================

# Get the latest build of powerline-server

create-build-dir:
  file.directory:
    - name: /srv/civix/
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True

pull-deb:
  file.managed:
    - name: /srv/civix_{{ build }}_all.deb
    - user: {{ user }}
    - group: {{ user }}
    - source: {{ build_repo }}/{{ branch }}/civix_{{ build }}_all.deb
    - source_hash: {{ build_repo }}/{{ branch }}/civix_{{ build }}_all.deb.hash

# =============================
# ====== get parameters =======
# =============================

create-build-dir:
  file.directory:
    - name: /srv/config/
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True

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
    - prereq:
      - composer: composer-install

stop-fpm-for-deploy:
  service.dead:
    - name: php{{php_ver}}-fpm

# ===========================
# ====== Install latest =====
# ===========================

install-civix-build:
  pkg.installed:
    - sources:
      - civix: /srv/civix_{{ build }}_all.deb

# fix the console perms
console-perms:
  file.managed:
    - name: /srv/civix/bin/console
    - mode: 755
    - user: {{ user }}
    - group: {{ user }}

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
    - name: /srv/civix/bin/console cache:warmup --env={{ env }}
    - runas: {{ user }}

# Run migrations
doctrine-migrations:
  cmd.run:
    - name: /srv/civix/bin/console doctrine:migrations:migrate -n
    - runas: {{ user }}

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
    - name: civix:release
    - value: {{ rev }}

