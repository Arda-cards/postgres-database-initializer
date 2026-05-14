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
# pg_stat_statements, the initializer must exit non-zero (the default
# extensions floor includes pg_stat_statements and CREATE EXTENSION
# errors out without the preload).
echo ">>> Fail-loud verification (sut_no_preload — expected to exit non-zero)"
if docker compose -f src/test/docker/compose.yaml up --exit-code-from sut_no_preload sut_no_preload; then
  echo "FAIL: sut_no_preload exited 0 but was expected to fail (pg_stat_statements not preloaded)"
  exit 1
fi
echo ">>> PASS: sut_no_preload exited non-zero as expected"

echo ">>> SUCCESS <<<"
