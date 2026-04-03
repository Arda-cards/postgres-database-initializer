\echo 'Creating database' :"database_name" 'with role' :"database_role" 'for owner' :"database_owner"
\echo

SELECT * FROM pg_roles WHERE  rolname IN (:'database_owner', :'database_role');
SELECT * FROM pg_database WHERE datname = :'database_name';

SELECT
  EXISTS (SELECT 1 FROM pg_database WHERE datname = :'database_name') AS database_is_defined,
  EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'database_owner') AS owner_is_defined,
  EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'database_role') AS role_is_defined;
\gset

\set ECHO all

-- Role

\if :role_is_defined
  \echo 'Role' :"database_role" 'exists, skipping creation'
\else
  CREATE ROLE :"database_role";
\endif

-- Owner

\if :owner_is_defined
  \echo 'Role' :"database_owner" 'exists, skipping creation'
\else
  CREATE ROLE :"database_owner" WITH
    LOGIN
    IN ROLE :"database_role";
\endif
ALTER ROLE :"database_owner" WITH PASSWORD :'database_owner_password';

-- Database

ALTER ROLE :"database_owner" CREATEDB;
SET ROLE :"database_owner";
\if :database_is_defined
  \echo 'Database' :"database_name" 'exists, skipping creation'
\else
  CREATE DATABASE :"database_name";
\endif
ALTER DATABASE :"database_name" WITH CONNECTION_LIMIT = :connection_limit;
RESET ROLE;
ALTER ROLE :"database_owner" NOCREATEDB;

-- Grant the necessary permissions to the role
GRANT CONNECT ON DATABASE :"database_name" TO :"database_role";
GRANT CREATE ON DATABASE :"database_name" TO :"database_role";
GRANT TEMPORARY ON DATABASE :"database_name" TO :"database_role";

\c :"database_name"

-- Grant all privileges on all tables, sequences, and functions in the public schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO :"database_role";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO :"database_role";
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO :"database_role";

-- Create extensions as the current psql user (typically a superuser) after connecting to the database.
-- This is done here because creating these extensions requires superuser privileges that the application roles do not have.
SELECT format('CREATE EXTENSION IF NOT EXISTS %I', btrim(extension_name))
FROM regexp_split_to_table(:'extensions', ',') AS extension_name
WHERE btrim(extension_name) <> '';
\gexec

-- Revoke the ability to drop the database or create new users
REVOKE CREATE ON DATABASE :"database_name" FROM :"database_owner";
REVOKE CREATE ON DATABASE :"database_name" FROM :"database_role";
