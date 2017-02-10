{% set user = salt['pillar.get']('civix:user') %}
{% set rev = salt['pillar.get']('civix:deploy:rev') %}
{% set repo = salt['pillar.get']('civix:deploy:repo') %}
{% set build_files = salt['pillar.get']('civix:deploy:build_files') %}
{% set absent_files = salt['pillar.get']('civix:deploy:absent_files') %}

{% set env = salt['grains.get']('civix:environment') %}

{% set release = None|strftime("%Y%m%d%H%M%S") %}

# =========================
# ====== git-latest =======
# =========================

# Get the latest release of powerline-server

create-build-dir:
  file.directory:
    - name: /srv/powerline-server/{{ rev }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - makedirs: True

get-apiserver-repo:
  git.latest:
    - name: {{ repo }}
    - target: /srv/powerline-server/{{ rev }}
    - branch: {{ rev }}

# ==============================
# ====== prepare release =======
# ==============================

# Create a release dir so we can move in the right dirs
# and vendor (composer)
create-release-dir:
  file.directory:
    - name: /srv/powerline-server-releases/{{ rev }}
    - makedirs: True
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - require:
      - git: get-apiserver-repo

# A hackish way to copy files into to the new release
# Seems file.copy is broken
{% for bf in build_files %}
copy-{{ bf }}:
  cmd.run:
    - name: cp -R /srv/powerline-server/{{ rev }}/backend/{{ bf }} /srv/powerline-server-releases/{{ rev }}
{% endfor %}

# remove files/dirs we dont need
{% for af in absent_files %}
absent-files-{{ af }}:
  file.absent:
    - name: /srv/powerline-server-releases/{{ rev }}/{{ af }}
{% endfor %}

# fix the console perms
console-perms:
  file.managed:
    - name: /srv/powerline-server-releases/{{ rev }}/app/console
    - mode: 755
    - user: {{ user }}
    - group: {{ user }}

# This will pull in all parameters defined in the
# pillar for whatever env you are working on
# The env is defined by the grains of the instance
get-parameters:
  file.serialize:
    - name: /srv/powerline-server-releases/{{ rev }}/app/config/parameters.yml
    - mode: 644
    - user: {{ user }}
    - group: {{ user }}
    - dataset_pillar: civix:symfony
    - formatter: yaml

# =========================
# ====== composer =========
# =========================

# Pull down all vendors

composer-install:
  composer.installed:
    - name: /srv/powerline-server-releases/{{ rev }}
{% if env.startswith("prod") %}
    - no_dev: True
{% endif %}
    - prefer_dist: True

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
    - name: php5-fpm

# =========================
# ====== link in ==========
# =========================

link-latest-build:
  file.symlink:
    - name: /srv/civix/civix-apiserver
    - target: /srv/powerline-server-releases/{{ rev }}
    - user: {{ user }}
    - group: {{ user }}

# =========================
# ==== RESTART SERVICES ===
# =========================

#
restart-nginx-for-deploy:
  service.running:
    - name: nginx
    - watch:
      - file: link-latest-build

restart-fpm-for-deploy:
  service.running:
    - name: php5-fpm

# =========================
# ====== POST DEPLOY ======
# =========================

# Warm cache
warm-cache:
  cmd.run:
    - name: /srv/civix/civix-apiserver/app/console cache:warmup --env=prod
    - runas: {{ user }}

# Run migrations
doctrine-migrations:
  cmd.run:
    - name: /srv/civix/civix-apiserver/app/console doctrine:migrations:migrate -n

bounce-supervisor-push-queue:
  supervisord.running:
    - name: civix_push_queue
    - restart: True

#bounce-supervisor-payments:
#bounce-supervisor-subs:

# Add a release grain to the minion
app-build-version:
  grains.present:
    - name: civix:release
    - value: {{ rev }}

