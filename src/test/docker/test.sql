\set ON_ERROR_STOP on

DO $$
BEGIN
    IF (SELECT count(*) FROM pg_roles WHERE rolname = 'test_db_role') <> 1 THEN
        RAISE EXCEPTION 'User test_db_role does not exist';
    END IF;
END;
$$;

DO $$
BEGIN
    IF (SELECT datconnlimit FROM pg_database WHERE datname = 'test_db') <> 100 THEN
        RAISE EXCEPTION 'Connection limit is not equal to 100!';
    END IF;
END;
$$;
