#!/usr/bin/env sh

[ "${RUNNER_DEBUG}" = 1 ] && set -xv
set -eu

docker compose -f src/test/docker/compose.yaml down --remove-orphans --rmi local
docker rmi --force arda-cards/postgres-database-initializer

export COMPOSE_BAKE=true

docker compose -f src/test/docker/compose.yaml up --renew-anon-volumes --exit-code-from sut sut
docker compose -f src/test/docker/compose.yaml up --exit-code-from idempotency idempotency
docker compose -f src/test/docker/compose.yaml up --exit-code-from tester tester
docker compose -f src/test/docker/compose.yaml up --exit-code-from sut_all sut_all
docker compose -f src/test/docker/compose.yaml up --exit-code-from tester_all tester_all
docker compose -f src/test/docker/compose.yaml up --exit-code-from teardown teardown
docker compose -f src/test/docker/compose.yaml up --exit-code-from teardown_empty teardown_empty
