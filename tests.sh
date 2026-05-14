#!/usr/bin/env sh

[ "${RUNNER_DEBUG}" = 1 ] && set -xv
set -eu

run() {
  "$@"
  exit_code=$?
  if [ "$exit_code" -ne 0 ]; then
    echo "FAIL: $*"
    exit "$exit_code"
  fi
}

run docker compose -f src/test/docker/compose.yaml down --remove-orphans --rmi local
run docker rmi --force arda-cards/postgres-database-initializer

export COMPOSE_BAKE=true

run docker compose -f src/test/docker/compose.yaml up --renew-anon-volumes --exit-code-from sut sut
run docker compose -f src/test/docker/compose.yaml up --exit-code-from idempotency idempotency
run docker compose -f src/test/docker/compose.yaml up --exit-code-from tester tester
run docker compose -f src/test/docker/compose.yaml up --exit-code-from sut_all sut_all
run docker compose -f src/test/docker/compose.yaml up --exit-code-from tester_all tester_all
run docker compose -f src/test/docker/compose.yaml up --exit-code-from teardown teardown
run docker compose -f src/test/docker/compose.yaml up --exit-code-from teardown_empty teardown_empty

# Fail-loud verification: when shared_preload_libraries does not include
# pg_stat_statements, the initializer must exit non-zero AND the failure
# must surface the specific preload-missing Postgres error. CREATE
# EXTENSION itself succeeds on PG 16+ — the failure comes from the
# verify query in create.sql that queries pg_stat_statements. Asserting
# the error string (not just a non-zero exit) prevents an unrelated
# build / dependency / daemon failure from masquerading as a passing
# negative test.
echo ">>> Fail-loud verification (sut_no_preload — expected preload-missing error)"
no_preload_log="$(mktemp)"
if docker compose -f src/test/docker/compose.yaml up --exit-code-from sut_no_preload sut_no_preload >"$no_preload_log" 2>&1; then
  echo "FAIL: sut_no_preload exited 0 but was expected to fail (pg_stat_statements not preloaded)"
  cat "$no_preload_log"
  rm -f "$no_preload_log"
  exit 1
fi
if ! grep -q "pg_stat_statements must be loaded via shared_preload_libraries" "$no_preload_log"; then
  echo "FAIL: sut_no_preload exited non-zero but did not surface the expected preload-missing error"
  echo "      Expected substring: 'pg_stat_statements must be loaded via shared_preload_libraries'"
  cat "$no_preload_log"
  rm -f "$no_preload_log"
  exit 1
fi
rm -f "$no_preload_log"
echo ">>> PASS: sut_no_preload failed with the expected preload-missing error"

echo ">>> SUCCESS <<<"
