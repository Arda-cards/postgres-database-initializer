#!/usr/bin/env sh

[ "${RUNNER_DEBUG}" = 1 ] && set -xv
set -eu

run() {
  "$@"
  exit_code=$?
  if [ $exit_code -ne 0 ]; then
    echo "FAIL: $*"
    exit $exit_code
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

echo ">>> SUCCESS <<<"
