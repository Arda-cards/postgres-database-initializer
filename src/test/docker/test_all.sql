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
