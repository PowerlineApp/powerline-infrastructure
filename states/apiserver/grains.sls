

civix-roles:
  grains.present:
    - name: civix:roles
    - value: apiserver

civix-project:
  grains.present:
    - name: civix:project
    - value: civix
