SHELL=/bin/bash

# Default to Debug for the optimization level
ifeq ($(OPTIMIZE),)
	OPTIMIZE = Debug
endif

# Set default build version
ifeq ($(VERSION),)
	VERSION = $(shell echo 1.$(shell echo $(shell date +"%y%m%d") | sed 's/^0*//').$(shell echo $(shell date +"%H%M%S") | sed 's/^0*//'))
endif

# Set default output folder
ifeq ($(OUTPUT_DIR),)
	OUTPUT_DIR = './'
endif

# Specify if nodejs should be used instead of bun
ifeq ($(USE_NODE),)
	USE_NODE = 0
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
	@bash ./watch.sh USE_NODE=$(USE_NODE) OPTIMIZE=$(OPTIMIZE)

test: clean ## Default Test Target.
	@zig build test
ifeq ($(USE_NODE),1)
	@npm run test --prefix ./site
else
	@bun -b run --cwd ./site test-bun
endif
	@make test-rust-lambda
	@make test-python-lambda

release: clean build-web build-site  ## Default Release Target. Builds Web Version for publish
ifeq ($(OPTIMIZE),Debug)
else
	@make build-rust-lambda build-python-lambda
endif

setup: setup-git-clone setup-python setup-emscripten setup-bun setup-rust # Default Setup Target. Sets up python (uv), emscripten, nodejs, playwright, and rust.

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
	@if [ -f "./emsdk/upstream/emscripten/emcc" ]; then ./emsdk/upstream/emscripten/emcc --check; else cd emsdk;./emsdk install latest --shallow;./emsdk activate latest;source ./emsdk_env.sh; fi
	@rm -fr ./emsdk/upstream/emscripten/tests

setup-bun: ## BUN Install
ifeq ($(USE_NODE),1)
	@npm install --prefix ./site
else
	@bun install --cwd ./site
endif
	
setup-docker: ## Docker Compose
	@docker compose build

setup-playwright: ## Setup Playwright
ifeq ($(USE_NODE),1)
	@npm exec --prefix ./site --no -- playwright install --with-deps;
else
	@bun --bun --cwd ./site playwright install --with-deps;
endif

setup-rust: ## Setup Rust Environment
	@cd ./rust-lambda; cargo fetch

setup-python: ## Setup Python Environment
	@rm -rf ./python-lambda/.venv
	@cd ./python-lambda && ~/.local/bin/uv venv .venv
	@cd ./python-lambda && . .venv/bin/activate && ~/.local/bin/uv pip install --target ./package -e . --link-mode=copy
	@rm -rf ./python-lambda/package/__pycache__

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
ifeq ($(PRECOMPRESS_RELEASE),1)
	@npm run build --prefix ./site -- -- --precompress --$(OPTIMIZE)
else
	@npm run build --prefix ./site -- -- --$(OPTIMIZE)
endif
else
ifeq ($(PRECOMPRESS_RELEASE),1)
	@bun -b --cwd ./site build -- -- --precompress --$(OPTIMIZE)
else
	@bun -b --cwd ./site build -- -- --$(OPTIMIZE)
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
	@docker build --rm --network=host --progress=plain -t dylanlangston.com . --target publish --output type=local,dest=$(OUTPUT_DIR) --build-arg VERSION=$(VERSION) --build-arg OPTIMIZE=$(OPTIMIZE) --build-arg PRECOMPRESS_RELEASE=$(PRECOMPRESS_RELEASE)

test-docker:  ## clean, setup, and test using docker.
	@docker build --rm --network=host --secret id=gemini_api_key,env=GEMINI_API_KEY --progress=plain -t dylanlangston.com . --target test --build-arg VERSION=$(VERSION) --build-arg OPTIMIZE=$(OPTIMIZE)

run-site: build-web ## Run Website
ifeq ($(USE_NODE),1)
	@npm run dev --prefix ./site -- -- --$(OPTIMIZE)
else
	@bun -b run --cwd ./site dev -- -- --$(OPTIMIZE)
endif

update-version: ## Update Version. Optionally pass in the VERSION=1.0.0 argument.
	@sed -i -r 's/ .version = "([[:digit:]]{1,}\.*){3,4}"/ .version = "$(VERSION)"/g' ./build.zig.zon
	@sed -i -r 's/"version": "([[:digit:]]{1,}\.*){3,4}"/"version": "$(VERSION)"/g' ./site/package.json
	@sed -i -r 's/version = "([[:digit:]]{1,}\.*){3,4}"$$/version = "$(VERSION)"/g' ./rust-lambda/Cargo.toml
	@echo Updated Version to $(VERSION)

build-rust-lambda: ## Build the Contact API and EmailForward Lambda
	@cd ./rust-lambda; cargo lambda build --release --arm64 --output-format zip --target-dir ./target

test-rust-lambda: setup-rust ## Test the Contact API Lambda
	@cd ./rust-lambda; cargo test
	@cd ./rust-lambda; cargo lambda watch -w -A 127.0.0.1 -P 9999 &
	@timeout 30 bash -c 'while ! nc -z 127.0.0.1 9999; do sleep 1; done' || (pkill cargo-lambda && exit 1);
	@cd ./rust-lambda; cargo lambda invoke -A 127.0.0.1 -P 9999 "contact" --data-file ./TestData.json; pkill cargo-lambda


test-python-lambda: setup-python ## Test the Chat Lambda locally
	@cd ./python-lambda && . .venv/bin/activate && PYTHONPATH=src:package python -c "import chat; print(chat.lambda_handler({'httpMethod': 'POST', 'body': '{\"message\": \"Hello, who are you?\", \"history\": []}', 'headers': {'origin': 'https://dylanlangston.com'}}, None))"

build-python-lambda: setup-python ## Package the Chat Lambda
	@rm -f ./python-lambda/build/chat.zip
	@mkdir -p ./python-lambda/build/
	@cd ./python-lambda/package;zip -r ../build/chat.zip .;
	@cd ./python-lambda/src; zip ../build/chat.zip ./chat.py; 
	@cd ./resume/dist/; zip ../../python-lambda/build/chat.zip resume.md