SHELL=/bin/bash

# Default to Debug for the optimization level
ifeq ($(OPTIMIZE),)
	OPTIMIZE = 'Debug'
endif

# Set default build version
ifeq ($(VERSION),)
	VERSION = $(shell date +"1.%y%m%d.%H%M%S")
endif

# Specify if nodejs should be used instead of bun
ifeq ($(USE_NODE),)
	USE_NODE = 0
else ifeq ($(USE_NODE),0)
else ifeq ($(USE_NODE),1)
else
$(error "USE_NODE must be 1 or 0")
endif

help: ## Display the help menu.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

desktop: clean build-desktop run-desktop ## Default Desktop Target. clean, build, and run.

web: clean build-web run-site ## Default Web Target. clean, build, and run.

develop: ## Uses the watch.sh script to run an interative design loop.
ifeq ($(USE_NODE),1)
	@bash ./watch.sh USE_NODE=1
else
	@bash ./watch.sh USE_NODE=0
endif

test: clean setup-tests ## Default Test Target. clean, setup, and test
	@zig build test
ifeq ($(USE_NODE),1)
	@npm run test --prefix ./site
else
	@bun -b run --cwd ./site test
endif

release: clean build-web build-site ## Default Release Target. Builds Web Version for publish

setup: setup-git-clone setup-emscripten setup-bun # Default Setup Target. Clones git repos, sets up emscripten, and sets up nodejs.

clean: ## Default Clean Target.
	@rm -rf ./zig-out/*
	@rm -rf ./site/build/*
	@echo Cleaned Output

clean-cache: clean ## Clean the Zig-cache also
	@rm -rf ./zig-cache/*
	@echo Cleaned Cache

setup-git-clone: ## Clone git submodules
	@git submodule update --init --recursive

setup-emscripten: ## Install and Activate Emscripten
# Source: https://emscripten.org/docs/getting_started/downloads.html#installation-instructions-using-the-emsdk-recommended
	@cd emsdk;./emsdk install latest;./emsdk activate latest;source ./emsdk_env.sh

setup-bun: ## BUN Install
ifdef $(USE_NODE)
	@npm install --prefix ./site
else
	@bun install --cwd ./site
endif
	
setup-docker: ## Docker Compose
	@docker compose build

setup-tests: ## Setup Playwright
ifdef $(USE_NODE)
	@npx --yes playwright install
	@npx --yes playwright install-deps
else
	@bunx --bun playwright install
	@bunx --bun playwright install-deps
endif

build-desktop: ## Build Desktop. Optionally pass in the OPTIMIZE=... argument.
	@zig build -Doptimize=$(OPTIMIZE)

run-desktop: ## Run the build desktop binary
	@./zig-out/bin/dylanlangston.com

build-web: ## Build Web. Optionally pass in the OPTIMIZE=... argument.
# Want to try get this working maybe, but it will need a custom platform I think:
# zig build -Dtarget=wasm32-freestanding -Doptimize=$(OPTIMIZE)
	@zig build -Dtarget=wasm32-emscripten -Doptimize=$(OPTIMIZE)

build-site: ## Build Website.
ifdef $(USE_NODE)
	@npm run build --prefix ./site
else
	@bun -b run --cwd ./site build
endif
	
develop-docker-start: setup-docker develop-docker-stop ## Launch a docker container. Control-C to quit.
	@docker compose up -d 
	@docker compose logs -f && exit 1 || docker compose down --remove-orphans --rmi 'all'
	@echo Starting Docker Container

develop-docker-stop: ## Stop all docker containers
	@docker compose down --remove-orphans --rmi 'all'
	@echo Stopping Docker Container

release-docker:  ## Builds Web Version for publish using docker.
	@docker build --cache-from dylanlangston.com:latest -t dylanlangston.com . --target publish --build-arg VERSION=$(VERSION) --build-arg OPTIMIZE=$(OPTIMIZE)
	@docker create --name site-temp dylanlangston.com
	@docker cp site-temp:/root/dylanlangston.com/site/build/ ./site/
	@docker rm -f site-temp

test-docker:  ## clean, setup, and test using docker.
	@docker build --cache-from dylanlangston.com:latest -t dylanlangston.com . --target test --build-arg VERSION=$(VERSION) --build-arg OPTIMIZE=$(OPTIMIZE)

run-site: build-web ## Run Website
ifeq ($(USE_NODE),1)
	@npm run dev --prefix ./site
else
	@bun -b run --cwd ./site dev
endif

update-version: ## Update Version. Optionally pass in the VERSION=1.0.0 argument.
	@sed -i -r 's/ .version = "([[:digit:]]{1,}\.*){3,4}"/ .version = "$(VERSION)"/g' ./build.zig.zon
	@sed -i -r 's/	"version": "([[:digit:]]{1,}\.*){3,4}"/	"version": "$(VERSION)"/g' ./site/package.json
	@echo Updated Version to $(VERSION)