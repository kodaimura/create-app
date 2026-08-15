.PHONY: build run test shell clean help

build:
	docker compose build

run:
	docker compose run --rm --build app

test:
	docker compose run --rm --build app go test ./...

shell:
	docker compose run --rm --build app sh

clean:
	docker compose down --remove-orphans

help:
	@echo "make build  Build the container image"
	@echo "make run    Run the script"
	@echo "make test   Run tests"
	@echo "make shell  Open a shell"
	@echo "make clean  Remove Compose resources"
