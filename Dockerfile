# syntax=docker/dockerfile:1

# Using Debian Latest
FROM debian:stable-slim as base
USER root

ENV PATH="/root/.bun/bin/:/root/.zvm/self/:/root/.zvm/bin:/root/.cargo/bin:$PATH"
WORKDIR /root/dylanlangston.com

# Copy only the files we absolutely need
COPY ./.gitmodules /root/dylanlangston.com/.gitmodules
COPY ./Makefile /root/dylanlangston.com/Makefile
COPY ./emsdk /root/dylanlangston.com/emsdk
COPY ./setup-build.sh /root/dylanlangston.com/setup-build.sh
COPY ./site/package.json /root/dylanlangston.com/site/package.json
COPY ./site/bun.lockb /root/dylanlangston.com/site/bun.lockb
COPY ./site/bunfig.toml /root/dylanlangston.com/site/bunfig.toml
COPY ./rust-lambda/Cargo.toml /root/dylanlangston.com/rust-lambda/Cargo.toml
COPY ./rust-lambda/Cargo.lock /root/dylanlangston.com/rust-lambda/Cargo.lock
COPY ./rust-lambda/src /root/dylanlangston.com/rust-lambda/src

# Setup Build Environment
RUN sh ./setup-build.sh

# Cleanup
RUN rm -rf ./site/src
RUN rm -rf ./site/static
RUN rm -rf ./site/tests
RUN rm -f ./site/*.*
RUN rm -rf ./rust-lambda/src
RUN rm -rf ./.gitmodules
RUN rm -rf ./Makefile
RUN rm -rf ./setup-build.sh

FROM base as test
COPY . /root/dylanlangston.com/
RUN make setup-git-clone build-web test USE_NODE=1

FROM base AS develop
EXPOSE 5173
CMD ["make", "develop", "USE_NODE=1"]

FROM base AS publish
COPY . /root/dylanlangston.com/
ARG VERSION
RUN test -n "$VERSION"
ARG OPTIMIZE='Debug'
RUN test -n "$OPTIMIZE"
ARG PRECOMPRESS_RELEASE='0'
RUN test -n "$PRECOMPRESS_RELEASE"
RUN make setup-git-clone update-version VERSION=$VERSION release OPTIMIZE=$OPTIMIZE USE_NODE=1 PRECOMPRESS_RELEASE=$PRECOMPRESS_RELEASE

# Default Stage is the Base stage
FROM base as default