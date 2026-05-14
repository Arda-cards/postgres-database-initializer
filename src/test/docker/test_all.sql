\set ON_ERROR_STOP on

DO $$
BEGIN
    IF (SELECT count(*) FROM pg_roles WHERE rolname = 'test_db_all_role') <> 1 THEN
        RAISE EXCEPTION 'User test_db_all_role does not exist';
    END IF;
END;
$$;

DO $$
BEGIN
    IF (SELECT datconnlimit FROM pg_database WHERE datname = 'test_db_all') <> 25 THEN
        RAISE EXCEPTION 'Connection limit is not equal to 25!';
    END IF;
END;
$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm') THEN
        RAISE EXCEPTION 'Extension pg_trgm was not created';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'btree_gin') THEN
        RAISE EXCEPTION 'Extension btree_gin was not created';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'btree_gist') THEN
        RAISE EXCEPTION 'Extension btree_gist was not created';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_stat_statements') THEN
        RAISE EXCEPTION 'Extension pg_stat_statements was not created';
    END IF;
END;
$$;
