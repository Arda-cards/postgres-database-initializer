#!/usr/bin/env sh

readonly pgenv=/home/.pgenv
export PGPASSFILE=/home/.pgpass

# If an entry needs to contain : or \, escape this character with \
pg_escape() {
  # shellcheck disable=SC2059
  printf "$(echo "${1}" |sed -e 's/\\/\\\\\\\\/g' -e 's/:/\\\\:/g')${2}"
}


if [ -f ${pgenv} ]; then
  if [ -f ${PGPASSFILE} ]; then
    echo "Can't have both ${pgenv} and ${PGPASSFILE}"
    exit 1
  fi

  pg_user="$(grep -m 1 '^PGUSER=' ${pgenv} | cut -d '=' -f 2)"
  pg_pw="$(grep -m 1 '^PGPASSWORD=' ${pgenv} | cut -d '=' -f 2)"
  {
    printf "*:*:*:"
    pg_escape "${pg_user}" ":"
    pg_escape "${pg_pw}" "\n"
  } > ${PGPASSFILE}
else
  echo "WARNING: Handling of user name with escapes is not supported"
  pg_user="$(grep -v -e '^#' ${PGPASSFILE} | cut -d : -f 4)"
fi
chmod -f 0600 ${PGPASSFILE}

readonly values=/home/values.properties
{
echo "\set database_name '$(grep -e '^database_name=' "${values}" | cut -d = -f 2)'"
echo "\set database_owner '$(grep '^database_owner=' "${values}" | cut -d = -f 2)'"
echo "\set database_owner_password '$(grep '^database_owner_password=' "${values}" | cut -d = -f 2)'"
connection_limit=$(grep '^connection_limit=' "${values}" | cut -d = -f 2)
echo "\set connection_limit ${connection_limit:-100}"
} > /home/values.sql

psql -U $pg_user --no-password \
  --set ON_ERROR_STOP=on \
  -f /home/values.sql -f /home/database-init.sql \
  "$@"
