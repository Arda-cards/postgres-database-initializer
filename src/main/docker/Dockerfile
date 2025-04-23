FROM postgres:17-alpine3.20

COPY entrypoint.sh /home/entrypoint.sh
COPY database-init.sql /home/database-init.sql

ENTRYPOINT [ "/home/entrypoint.sh" ]
