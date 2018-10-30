
time-sync:
  cron.present:
    - name: ntpdate ntp.ubuntu.com
    - special: "@daily"
