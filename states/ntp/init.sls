ntp:
  pkg.installed

manage-ntp:
  service.running:
    - name: ntp
    - enable: True
    - reload: True
    - onchanges:
      - pkg: ntp
