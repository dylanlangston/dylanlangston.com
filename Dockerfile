# syntax=docker/dockerfile:1

# Using Debian Latest
FROM debian:stable-slim as base
USER root

# Copy only the files we absolutely need
COPY ./site/package.json /root/dylanlangston.com/site/package.json
COPY ./site/bun.lockb /root/dylanlangston.com/site/bun.lockb
COPY ./site/bunfig.toml /root/dylanlangston.com/site/bunfig.toml
COPY ./.gitmodules /root/dylanlangston.com/.gitmodules
COPY ./Makefile /root/dylanlangston.com/Makefile
COPY ./setup-build.sh /root/dylanlangston.com/setup-build.sh
COPY ./emsdk /root/dylanlangston.com/emsdk

# Setup Build Environment
ENV PATH="/root/.bun/bin/:/root/.zvm/self/:/root/.zvm/bin:$PATH"
WORKDIR /root/dylanlangston.com
RUN sh ./setup-build.sh

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