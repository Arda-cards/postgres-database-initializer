\du

\set ON_ERROR_STOP on

--  scope.test_DB_role
SELECT * FROM pg_roles;
DO $$
BEGIN
    IF (SELECT count(*) FROM pg_roles WHERE rolname = 'scope.test_DB_role') <> 1 THEN
        RAISE EXCEPTION 'User scope.test_DB_role does not exist';
    END IF;
    IF (SELECT rolcreatedb FROM pg_roles WHERE rolname = 'scope.test_DB_role') THEN
        RAISE EXCEPTION 'User scope.test_DB_role has privilege to create database';
    END IF;
END;
$$;
--  scope.test-DB-owner
DO $$
BEGIN
    IF (SELECT count(*) FROM pg_roles WHERE rolname = 'scope.test-DB-owner') <> 1 THEN
        RAISE EXCEPTION 'User scope.test-DB-owner does not exist';
    END IF;
    IF (SELECT rolcreatedb FROM pg_roles WHERE rolname = 'scope.test-DB-owner') THEN
        RAISE EXCEPTION 'User scope.test-DB-owner has privilege to create database';
    END IF;
END;
$$;

SELECT * FROM pg_database;
DO $$
BEGIN
    IF (SELECT datconnlimit FROM pg_database WHERE datname = 'scope.test_DB') <> 100 THEN
        RAISE EXCEPTION 'Connection limit is not equal to 100!';
    END IF;
    IF (SELECT pg_get_userbyid(datdba) FROM pg_database WHERE datname = 'scope.test_DB') <> 'scope.test-DB-owner' THEN
        RAISE EXCEPTION 'Database owner is not equal to scope.test-DB-owner!';
    END IF;
END;
$$;

-- Default extensions floor: every database the initializer provisions
-- gets pg_trgm, btree_gin, and pg_stat_statements created in it.
SELECT * FROM pg_extension;
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm') THEN
        RAISE EXCEPTION 'Extension pg_trgm was not created';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'btree_gin') THEN
        RAISE EXCEPTION 'Extension btree_gin was not created';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN
        RAISE EXCEPTION 'Extension pg_stat_statements was not created';
    END IF;
END;
$$;
