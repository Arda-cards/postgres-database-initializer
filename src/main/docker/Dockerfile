FROM alpine:3.20

RUN apk add --update --no-cache postgresql16-client

COPY entrypoint.sh /home/entrypoint.sh
COPY database-init.sql /home/database-init.sql

ENTRYPOINT [ "/home/entrypoint.sh" ]
