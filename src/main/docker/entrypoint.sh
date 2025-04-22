#!/usr/bin/env sh

export PGPASSFILE=/home/.pgpass
chmod 0600 ${PGPASSFILE}
pg_user="$(grep -v -e '^#' ${PGPASSFILE} | cut -d : -f 4)"

psql -U $pg_user --set ON_ERROR_STOP=on \
  -f /home/values.sql -f /home/database-init.sql \
  "$@"
