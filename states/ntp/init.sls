ntp:
  pkg.installed

manage-ntp:
  service.running:
    - name: ntp
    - enable: True
    - reload: True
    - watch:
      - pkg: ntp
