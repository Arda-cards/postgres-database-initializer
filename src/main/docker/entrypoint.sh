#!/usr/bin/env sh

readonly pgenv=/home/.pgenv
export PGPASSFILE=/home/.pgpass

# If an entry needs to contain : or \, escape this character with \
pg_escape() {
  # shellcheck disable=SC2059
  printf "$(echo "${1}" | sed -e 's/\\/\\\\\\\\/g' -e 's/:/\\\\:/g')${2}"
}

if [ -f ${pgenv} ]; then
  if [ -f ${PGPASSFILE} ]; then
    echo "Can't have both ${pgenv} and ${PGPASSFILE}"
    exit 1
  fi

  pg_user="$(sed -n -e 's/^PGUSER=//p' ${pgenv})"
  pg_pw="$(sed -n -e 's/^PGPASSWORD=//p' ${pgenv})"
  {
    printf "*:*:*:"
    pg_escape "${pg_user}" ":"
    pg_escape "${pg_pw}" "\n"
  } >${PGPASSFILE}
else
  echo "WARNING: Handling of user name with escapes is not supported"
  pg_user="$(grep -v -e '^#' ${PGPASSFILE} | cut -d : -f 4)"
fi
chmod -f 0600 ${PGPASSFILE}

readonly values=/home/values.properties
{
  echo "\set database_name '$(sed -n -e 's/^database_name=//p' "${values}")'"
  echo "\set database_owner '$(sed -n -e 's/^database_owner=//p' "${values}")'"
  echo "\set database_owner_password '$(sed -n -e 's/^database_owner_password=//p' "${values}")'"
  connection_limit=$(sed -n -e 's/^connection_limit=//p' "${values}" | cut -d = -f 2)
  echo "\set connection_limit ${connection_limit:-100}"
} >/home/values.sql

command=/home/create.sql
if [ $# = 2 ]; then
  if [ "$1" = "up" ]; then
    shift
    echo "Up"
  elif [ "$1" = "down" ]; then
    shift
    echo "Down"
    command=/home/destroy.sql
  else
    echo "Unrecognized argument $1."
    echo "Usage: [ up | down ] URI"
    echo "       defaults to up"
    exit 1
  fi
fi

psql -U $pg_user --no-password \
  -f /home/values.sql -f /home/setup.sql -f "${command}" \
  "$@"
