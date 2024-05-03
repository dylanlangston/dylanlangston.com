# syntax=docker/dockerfile:1.3.1

# Using Minideb Latest
FROM debian:stable-slim as base
USER root

RUN rm -f /etc/apt/apt.conf.d/docker-clean

ENV NODE_VERSION 20

ENV PATH="/root/.bun/bin/:/root/.zvm/self/:/root/.zvm/bin:/root/.cargo/bin:$PATH"
WORKDIR /root/dylanlangston.com

# Copy only the files we absolutely need
COPY ./.gitmodules /root/dylanlangston.com/.gitmodules
COPY ./emsdk /root/dylanlangston.com/emsdk
COPY ./site/package.json /root/dylanlangston.com/site/package.json
COPY ./site/bun.lockb /root/dylanlangston.com/site/bun.lockb
COPY ./site/bunfig.toml /root/dylanlangston.com/site/bunfig.toml
COPY ./rust-lambda/Cargo.toml /root/dylanlangston.com/rust-lambda/Cargo.toml
COPY ./rust-lambda/Cargo.lock /root/dylanlangston.com/rust-lambda/Cargo.lock
COPY ./Makefile /root/dylanlangston.com/Makefile

RUN apt-get update && apt-get -y install --no-install-recommends ca-certificates bash curl unzip xz-utils make git python3 build-essential pkg-config netcat-traditional

# Install ZVM - https://github.com/tristanisham/zvm
RUN curl --proto '=https' --tlsv1.3 -sSfL https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash
RUN echo "# ZVM" >> $HOME/.bashrc &&\
 echo export ZVM_INSTALL="$HOME/.zvm" >> $HOME/.bashrc &&\
 echo export PATH="\$PATH:\$ZVM_INSTALL/bin" >> $HOME/.bashrc &&\
 echo export PATH="\$PATH:\$ZVM_INSTALL/self" >> $HOME/.bashrc

# Install ZIG
RUN $HOME/.zvm/self/zvm i master

# Install ZLS
RUN $HOME/.zvm/self/zvm i -D=zls master

# Install rust
RUN curl --proto '=https' --tlsv1.3 -sSfL https://sh.rustup.rs | bash -s -- -y
RUN rustup target add aarch64-unknown-linux-gnu

# Install Cargo B(inary)Install
RUN curl --proto '=https' --tlsv1.3 -sSfL https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Install Cargo Lambda
RUN $HOME/.cargo/bin/cargo binstall cargo-lambda -y

# Install Node
RUN apt-get -y install --no-install-recommends nodejs npm

# Install Bun
#curl --proto '=https' --tlsv1.3 -fsSL https://bun.sh/install | bash

# Setup
RUN make setup USE_NODE=1

# Cleanup
RUN make clean-cache && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

RUN echo "Base Docker Image Build"

FROM base as test
COPY . /root/dylanlangston.com/
RUN make setup-git-clone build-web test USE_NODE=1

FROM base AS develop
EXPOSE 5173
CMD ["make", "develop", "USE_NODE=1"]

FROM base AS build
COPY . /root/dylanlangston.com/
ARG VERSION
RUN test -n "$VERSION"
ARG OPTIMIZE='Debug'
RUN test -n "$OPTIMIZE"
ARG PRECOMPRESS_RELEASE='0'
RUN test -n "$PRECOMPRESS_RELEASE"
RUN make setup-git-clone update-version VERSION=$VERSION release OPTIMIZE=$OPTIMIZE USE_NODE=1 PRECOMPRESS_RELEASE=$PRECOMPRESS_RELEASE

# Export files
FROM scratch AS publish
COPY --from=build /root/dylanlangston.com/site/build/ /site/build
COPY --from=build /root/dylanlangston.com/rust-lambda/target*/contact* /rust-lambda/target/contact
COPY --from=build /root/dylanlangston.com/rust-lambda/target*/email-forward* /rust-lambda/target/email-forward

# Default Stage is the Base stage
FROM base as default