# postgres-database-initializer

Init container to create a Postgres database

*Given* a Postgres connection string and the two files `.pgpass` and `values.properties`
*When* the container runs with the two files mounted
*Then* a database is created as configured by the `values.properties`


## PG Password

Mount the pgpass file at `/home/.pgpass`.

## Values

Mount the vales at `/home/values.properties`.

 Property               | Required | Description                                    
------------------------|----------|------------------------------------------------
 database_name          | yes      | Name of tha database                           
 database_owner         | yes      | Name of the database owqner                    
 database_owner_passwor | yes      | Password for the database owner                
 connection_limit       | no       | Initial connection cout limit, defaults to 100 

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
docker system prune
docker rmi arda-cards/postgres-database-initializer
```
