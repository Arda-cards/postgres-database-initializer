\echo 'Destroying database' :"database_name" 'with role' :"database_role" 'and owner' :"database_owner"
\echo

SELECT * FROM pg_roles WHERE  rolname IN (:'database_owner', :'database_role');
SELECT * FROM pg_database WHERE datname = :'database_name';

SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = :'database_owner') AS is_user_defined;
\gset

\if :is_user_defined
SET ROLE :"database_owner";
DROP DATABASE IF EXISTS :"database_name";
RESET ROLE;
\endif

DROP ROLE IF EXISTS :"database_owner";
DROP ROLE IF EXISTS :"database_role";
