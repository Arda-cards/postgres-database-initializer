# postgres-database-initializer

Init container to create a Postgres database

*Given* a Postgres connection string, `values.properties` and one of the two files `.pgenv` or `.pgpass`
*When* the container runs with the two files mounted
*Then* a database is created as configured by the `values.properties`

## values.properties

A property file, it contains un-escaped values to define the database to be created.

Keys and values are separated with a `=`. Comment lines, starting with a `#`, are ignored.

| Property               | Required | Description                                    |
|------------------------|----------|------------------------------------------------|
| database_name          | yes      | Name of the database                           |
| database_owner         | yes      | Name of the database owner                     |
| database_owner_passwor | yes      | Password for the database owner                |
| connection_limit       | no       | Initial connection cout limit, defaults to 100 |

Mount the file at `/home/values.properties`.

## .pgenv

A property file, it contains un-escaped values for the master user name and password.
`entrypoint.sh` will generate a correct `.pgpass` at run time.

Keys and values are separated with a `=`. Comment lines, starting with a `#`, are ignored.


| Property   | Required | Description                  |
|------------|----------|------------------------------|
| PGUSER     | yes      | Name of the master user      |
| PGPASSWORD | yes      | Password for the master user |

Mount the file at `/home/.pgenv`.

## .pgpass

A standard postgres [password file](https://www.postgresql.org/docs/16/libpq-pgpass.html), it needs only specify the master user
and master user password and can use wildcard for the host, port and database.
Note thay it _must_ apply the escaping rules.

Mount the file at `/home/.pgpass`.

# How to build

```shell
docker buildx build src/main/docker --tag arda-carda/postgres-database-initializer
```

# How to test

```shell
docker compose -f src/test/docker/compose.yaml up --renew-anon-volumes
```

This will build the image if not present.

Then inspect the log.

The script `tests.sh` runs all the integration tests.

# How to use

```shell
docker run postgres-database-
```

# Debug the image

```shell
docker run -it --entrypoint bash postgres:16
```

# Cleanup

```shell
docker system prune --volumes
docker rmi arda-cards/postgres-database-initializer
```
