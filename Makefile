
doc: ## generate doc (requires vimdoc)
	vimdoc .
test: ## run tests
	vim -c 'Vader! test/*' > /dev/null


help:
	@grep -E -h '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: doc test help
.DEFAULT_GOAL := help
