.PHONY: build test clean
.DEFAULT_GOAL := usage

SOURCES := src/main/docker
TEST_SOURCES := src/test/docker


usage:
	@echo "Makefile commands:"
	@echo "  make build           - Build the docker image"
	@echo "  make clean           - Clean build artifacts"

out/build.sentinel: $(SOURCES)
	@clear
	docker buildx build src/main/docker --tag arda-cards/postgres-database-initializer
	@mkdir -p out
	@touch out/build.sentinel

build: out/build.sentinel

test: build $(TEST_SOURCES)
	@clear
	./tests.sh

clean:
	@clear
	rm -rf out
	docker system prune --volumes --force; ./tests.sh
