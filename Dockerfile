# syntax=docker/dockerfile:1

# Using Debian Latest
FROM debian:stable-slim as base
USER root
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends ca-certificates bash curl unzip xz-utils make git python3
# Install ZVM - https://github.com/tristanisham/zvm
RUN curl https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash
ENV PATH="/root/.bun/bin/:/root/.zvm/self/:/root/.zvm/bin:$PATH"
RUN zvm i master
# Install Node
RUN apt-get -y install --no-install-recommends nodejs npm
# Install Bun
#RUN curl -fsSL https://bun.sh/install | bash
# Copy only the files we absolutely need
COPY ./site/package.json /root/dylanlangston.com/site/package.json
COPY ./site/bun.lockb /root/dylanlangston.com/site/bun.lockb
COPY ./site/bunfig.toml /root/dylanlangston.com/site/bunfig.toml
COPY ./.gitmodules /root/dylanlangston.com/.gitmodules
COPY ./Makefile /root/dylanlangston.com/Makefile
COPY ./emsdk /root/dylanlangston.com/emsdk
WORKDIR /root/dylanlangston.com
RUN make clean-cache setup USE_NODE=1
RUN apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

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
RUN make setup-git-clone update-version VERSION=$VERSION release OPTIMIZE=$OPTIMIZE USE_NODE=1

# Default Stage is the Base stage
FROM base as default