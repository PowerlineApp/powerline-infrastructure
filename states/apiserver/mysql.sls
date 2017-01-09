mysql-server-5.6:
  pkg.installed

mysql-civix-user:
  mysql_user.present:
    - name: civix
    - host: localhost
    - password: civix

mysql-civix-db:
  mysql_database.present:
    - name: civix

mysql-grant-all:
  mysql_grants.present:
    - grant: all privileges
    - database: civix.*
    - user: civix
    - host: localhost
