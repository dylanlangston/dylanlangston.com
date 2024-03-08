# syntax=docker/dockerfile:1

# Using Debian Latest
FROM debian:stable-slim as base
USER root

ENV PATH="/root/.bun/bin/:/root/.zvm/self/:/root/.zvm/bin:/root/.cargo/bin:$PATH"
WORKDIR /root/dylanlangston.com

# Copy only the files we absolutely need
COPY --link ./site/package.json /root/dylanlangston.com/site/package.json
COPY --link ./site/bun.lockb /root/dylanlangston.com/site/bun.lockb
COPY --link ./site/bunfig.toml /root/dylanlangston.com/site/bunfig.toml
COPY --link ./contact-lambda /root/dylanlangston.com/contact-lambda
COPY --link ./.gitmodules /root/dylanlangston.com/.gitmodules
COPY --link ./Makefile /root/dylanlangston.com/Makefile
COPY --link ./emsdk /root/dylanlangston.com/emsdk
COPY --link ./setup-build.sh /root/dylanlangston.com/setup.sh

# Setup Build Environment
RUN sh ./setup.sh

FROM base as test
COPY --link . /root/dylanlangston.com/
RUN make setup-git-clone build-web test USE_NODE=1

FROM base AS develop
EXPOSE 5173
CMD ["make", "develop", "USE_NODE=1"]

FROM base AS publish
COPY --link . /root/dylanlangston.com/
ARG VERSION
RUN test -n "$VERSION"
ARG OPTIMIZE='Debug'
RUN test -n "$OPTIMIZE"
ARG PRECOMPRESS_RELEASE='0'
RUN test -n "$PRECOMPRESS_RELEASE"
RUN make setup-git-clone update-version VERSION=$VERSION release OPTIMIZE=$OPTIMIZE USE_NODE=1 PRECOMPRESS_RELEASE=$PRECOMPRESS_RELEASE

# Default Stage is the Base stage
FROM base as default