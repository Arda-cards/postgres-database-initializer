#!/usr/bin/env sh

export PGPASSFILE=/home/.pgpass
chmod -f 0600 ${PGPASSFILE}

pg_user="$(grep -v -e '^#' ${PGPASSFILE} | cut -d : -f 4)"

. /home/values.properties

{
echo "\set database_name '${database_name}'"
echo "\set database_owner '${database_owner}'"
echo "\set database_owner_password '${database_owner_password}'"
echo "\set connection_limit ${connection_limit:-100}"
} > /home/values.sql

psql -U $pg_user --set ON_ERROR_STOP=on \
  -f /home/values.sql -f /home/database-init.sql \
  "$@"
