SHELL=/bin/bash

# Default to Debug for the optimization level
ifeq ($(OPTIMIZE),)
	OPTIMIZE = Debug
endif

# Set default build version
ifeq ($(VERSION),)
	VERSION = $(shell echo 1.$(shell echo $(shell date +"%y%m%d") | sed 's/^0*//').$(shell echo $(shell date +"%H%M%S") | sed 's/^0*//'))
endif

# Specify if nodejs should be used instead of bun
ifeq ($(USE_NODE),)
	USE_NODE = 1
else ifeq ($(USE_NODE),0)
else ifeq ($(USE_NODE),1)
else
$(error "USE_NODE must be 1 or 0")
endif

# Specify if release should be precompressed or not
ifeq ($(PRECOMPRESS_RELEASE),)
	PRECOMPRESS_RELEASE = 0
else ifeq ($(PRECOMPRESS_RELEASE),0)
else ifeq ($(PRECOMPRESS_RELEASE),1)
else
$(error "PRECOMPRESS_RELEASE must be 1 or 0")
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

test: clean ## Default Test Target. clean, setup, and test
	@zig build test
ifeq ($(USE_NODE),1)
	@npm run test --prefix ./site
else
	@bun -b run --cwd ./site test-bun
endif
	@make test-rust-lambda

release: clean build-web build-site  ## Default Release Target. Builds Web Version for publish
ifeq ($(OPTIMIZE),Debug)
else
	@make build-rust-lambda
endif

setup: setup-emscripten setup-bun setup-tests setup-rust # Default Setup Target. Clones git repos, sets up emscripten, sets up nodejs, and sets up rust.

clean: ## Default Clean Target.
	@rm -rf ./zig-out/*
	@rm -rf ./site/build/*
	@rm -rf ./rust-lambda/target/*
	@echo Cleaned Output

clean-cache: clean ## Clean the Zig-cache also
	@rm -rf ./zig-cache/*
	@cargo clean --manifest-path ./rust-lambda/Cargo.toml || true
	@echo Cleaned Cache

setup-git-clone: ## Clone git submodules
	@git submodule update --init --recursive

setup-emscripten: ## Install and Activate Emscripten
# Source: https://emscripten.org/docs/getting_started/downloads.html#installation-instructions-using-the-emsdk-recommended
	@cd emsdk;./emsdk install latest;./emsdk activate latest;source ./emsdk_env.sh

setup-bun: ## BUN Install
ifeq ($(USE_NODE),1)
	@npm install --prefix ./site
else
	@bun install --cwd ./site
endif
	
setup-docker: ## Docker Compose
	@docker compose build

setup-tests: ## Setup Playwright
ifeq ($(USE_NODE),1)
	@npx --yes playwright install
	@npx --yes playwright install-deps
else
	@bunx --bun playwright install
	@bunx --bun playwright install-deps
endif

setup-rust: ## Setup Rusy Environment
	@rustup target add aarch64-unknown-linux-gnu
	@cd ./rust-lambda; cargo fetch; cd ..

build-desktop: ## Build Desktop. Optionally pass in the OPTIMIZE=... argument.
	@zig build -Doptimize=$(OPTIMIZE) -freference-trace

run-desktop: ## Run the build desktop binary
	@./zig-out/bin/dylanlangston.com

build-web: ## Build Web. Optionally pass in the OPTIMIZE=... argument.
# Want to try get this working maybe, but it will need a custom platform I think:
# zig build -Dtarget=wasm64-freestanding -Doptimize=$(OPTIMIZE) -Dcpu=mvp+atomics+bulk_memory 
	@zig build -Dtarget=wasm32-emscripten -Dcpu=mvp+simd128+relaxed_simd+bulk_memory+nontrapping_fptoint -Doptimize=$(OPTIMIZE) -freference-trace

build-site: ## Build Website. Uses Binaryen to optimize when OPTIMIZE!='Debug', the default.
ifeq ($(USE_NODE),1)
ifeq ($(OPTIMIZE),Debug)
else
	@cd ./site; npm exec --package=binaryen -c 'wasm-opt ./static/dylanlangston.com.wasm -all --post-emscripten --low-memory-unused -tnh --converge -Oz --flatten --rereloop -Oz -Oz -o ./static/dylanlangston.com.wasm'; cd ../
endif
ifeq ($(PRECOMPRESS_RELEASE),1)
	@npm run build --prefix ./site -- -- --precompress
else
	@npm run build --prefix ./site
endif
else
ifeq ($(OPTIMIZE),Debug)
else
	@cd ./site; bunx --bun binaryen ./static/dylanlangston.com.wasm -all --post-emscripten --low-memory-unused -tnh --converge -Oz --flatten --rereloop -Oz -Oz -o ./static/dylanlangston.com.wasm; cd ../
endif
ifeq ($(PRECOMPRESS_RELEASE),1)
	@bun -b run --cwd ./site build -- -- --precompress
else
	@bun -b run --cwd ./site build
endif
endif
	
develop-docker-start: setup-docker develop-docker-stop ## Launch a docker container. Control-C to quit.
	@docker compose up -d 
	@docker compose logs -f && exit 1 || docker compose down --remove-orphans --rmi 'all'
	@echo Starting Docker Container

develop-docker-stop: ## Stop all docker containers
	@docker compose down --remove-orphans --rmi 'all'
	@echo Stopping Docker Container

release-docker:  ## Builds Web Version for publish using docker.
	@docker buildx build --load --network host -t dylanlangston.com . --target publish --build-arg VERSION=$(VERSION) --build-arg OPTIMIZE=$(OPTIMIZE) --build-arg PRECOMPRESS_RELEASE=$(PRECOMPRESS_RELEASE)
	@docker create --name site-temp dylanlangston.com
	@docker cp site-temp:/root/dylanlangston.com/site/build/ ./site/
ifeq ($(OPTIMIZE),Debug)
else
	@docker cp site-temp:/root/dylanlangston.com/rust-lambda/target/ ./rust-lambda/
endif
	@docker rm -f site-temp

test-docker:  ## clean, setup, and test using docker.
	@docker buildx build --network host -t dylanlangston.com . --target test --build-arg VERSION=$(VERSION) --build-arg OPTIMIZE=$(OPTIMIZE)

run-site: build-web ## Run Website
ifeq ($(USE_NODE),1)
	@npm run dev --prefix ./site
else
	@bun -b run --cwd ./site dev
endif

update-version: ## Update Version. Optionally pass in the VERSION=1.0.0 argument.
	@sed -i -r 's/ .version = "([[:digit:]]{1,}\.*){3,4}"/ .version = "$(VERSION)"/g' ./build.zig.zon
	@sed -i -r 's/"version": "([[:digit:]]{1,}\.*){3,4}"/"version": "$(VERSION)"/g' ./site/package.json
	@sed -i -r 's/version = "([[:digit:]]{1,}\.*){3,4}"$$/version = "$(VERSION)"/g' ./rust-lambda/Cargo.toml
	@echo Updated Version to $(VERSION)

build-rust-lambda: ## Build the Contact API Lambda
	@cd ./rust-lambda; cargo lambda build --release --target aarch64-unknown-linux-gnu --output-format zip -l ./target

test-rust-lambda: ## Test the Contact API Lambda
	@cd ./rust-lambda; cargo test
	@cd ./rust-lambda; cargo lambda watch -w & sleep 5;
	@cd ./rust-lambda; cargo lambda invoke "contact" --data-file ./TestData.json; pkill cargo-lambda