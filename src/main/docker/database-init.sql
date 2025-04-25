SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'database_owner') AS is_user_defined;
\gset

\if :is_user_defined
  \echo 'User' :database_owner 'exists, assuming database' :database_name 'has been properly setup already'
  \quit
\endif

\set database_role :database_name _role

-- Create the user
CREATE USER :database_owner WITH PASSWORD :'database_owner_password';

-- Create the database
CREATE DATABASE :database_name
  CONNECTION_LIMIT = :connection_limit
  OWNER = :database_owner;

-- Create a role with the required permissions
CREATE ROLE :database_role;

-- Grant the role to the user
GRANT :database_role TO :database_owner;

-- Grant the necessary permissions to the role
GRANT CONNECT ON DATABASE :database_name TO :database_role;
GRANT CREATE ON DATABASE :database_name TO :database_role;
GRANT TEMPORARY ON DATABASE :database_name TO :database_role;

-- Grant all privileges on all tables, sequences, and functions in the public schema
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO :database_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO :database_role;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO :database_role;

-- Revoke the ability to drop the database or create new users
REVOKE CREATE ON DATABASE :database_name FROM :database_owner;
REVOKE CREATE ON DATABASE :database_name FROM :database_role;
