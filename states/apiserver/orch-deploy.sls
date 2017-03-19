# API Server orchestration state for code deployment
#
# Deploys the api server code based on build number and
# targets machines based on branch
#
# To run a test:
# salt-run state.orchestrate apiserver.orch-deploy pillar='{"build_number": 135, "build_branch":"develop"}'

{% set number = salt['pillar.get']('build_number') %}
{% set target = {
   'develop' : 'civix:environment:development',
   'master'  : 'civix:environment:staging'}.get( salt['pillar.get']('build_branch') ) %}

ci-deploy:
  salt.state:
    - tgt: '{{ target }}'
    - tgt_type: grain
    - sls:
      - apiserver.deploy
    - pillar:
        build: {{ number }}
