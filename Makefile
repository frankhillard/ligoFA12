SHELL := /bin/bash

help:
	@grep -E '^[ a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

ifndef LIGO
LIGO=docker run -u $(id -u):$(id -g) --rm -v "$(PWD)":"$(PWD)" -w "$(PWD)" ligolang/ligo:0.67.1
endif
# ^ use LIGO en var bin if configured, otherwise use docker

compile = $(LIGO) compile contract --project-root ./lib ./lib/$(1) -o ./compiled/$(2) $(3) 
# ^ Compile contracts to Michelson or Micheline

test = @$(LIGO) run test $(project_root) ./test/$(1)
# ^ run given test file


.PHONY: test
test: ## run tests (SUITE=single_asset make test)
ifndef SUITE
	@$(call test,asset_transfer.test.mligo)
	@$(call test,asset_approve.test.mligo)
else
	@$(call test,$(SUITE).test.mligo)
endif

publish: ## publish package on packages.ligolang.org
	@$(LIGO) publish