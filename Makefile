SHELL:=/bin/bash
.DEFAULT_GOAL:=help

##@ Development

.PHONY: enable_git_hooks check_for_secrets

enable_git_hooks: ## Enables secret disclosure checks via pre-commit hook
		@/bin/bash .make/git_hooks.sh

check_for_secrets: ## Scan local project files looking for dangerous secrets (this is also run as pre-commit hook)
		@/bin/bash .make/check_for_secrets.sh


##@ Helpers

.PHONY: help

help:  ## Display this help
		@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
