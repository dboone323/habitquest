COMPOSE=Tools/docker-compose.yml

.PHONY: build tools swift cspell tools-all

build:
	@docker compose -f $(COMPOSE) build

tools:
	@docker compose -f $(COMPOSE) run --rm tools

swift:
	@docker compose -f $(COMPOSE) run --rm swift

cspell:
	@docker compose -f $(COMPOSE) run --rm cspell

tools-all:
	@docker compose -f $(COMPOSE) run --rm tools-all
