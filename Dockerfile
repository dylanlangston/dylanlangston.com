# syntax=docker/dockerfile:1.3.1

# Using Minideb Latest
FROM debian:stable-slim as base
USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=America/New_York

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

ENV PLAYWRIGHT_BROWSERS_PATH=/root/ms-playwright

ENV PATH="/root/.bun/bin/:/root/.zvm/self/:/root/.zvm/bin:/root/.cargo/bin:$PATH"
WORKDIR /root/dylanlangston.com

# Copy only the files we absolutely need
COPY ./emsdk /root/dylanlangston.com/emsdk
COPY ./site/package.json /root/dylanlangston.com/site/package.json
COPY ./site/package-lock.json /root/dylanlangston.com/site/package-lock.json
COPY ./site/bun.lockb /root/dylanlangston.com/site/bun.lockb
COPY ./site/bunfig.toml /root/dylanlangston.com/site/bunfig.toml
COPY ./rust-lambda/Cargo.toml /root/dylanlangston.com/rust-lambda/Cargo.toml
COPY ./rust-lambda/Cargo.lock /root/dylanlangston.com/rust-lambda/Cargo.lock
COPY ./python-lambda/src/dependencies.txt /root/dylanlangston.com/python-lambda/src/dependencies.txt
COPY ./Makefile /root/dylanlangston.com/Makefile

RUN apt-get update && apt-get -y install --no-install-recommends ca-certificates bash curl unzip xz-utils make git python3 pip build-essential pkg-config netcat-traditional procps zip \
# Everthing that follows are all deps for playwright
libasound2 libatk-bridge2.0-0 libatk1.0-0 libatspi2.0-0 libcairo2 libcups2 libdbus-1-3 libdrm2 libgbm1 libglib2.0-0 libnspr4 libnss3 libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 \
libxdamage1 libxext6 libxfixes3 libxkbcommon0 libxrandr2 xvfb fonts-noto-color-emoji fonts-unifont libfontconfig1 libfreetype6 xfonts-scalable fonts-liberation fonts-ipafont-gothic \
fonts-wqy-zenhei fonts-tlwg-loma-otf fonts-freefont-ttf libcairo-gobject2 libdbus-glib-1-2 libgdk-pixbuf-2.0-0 libgtk-3-0 libharfbuzz0b libpangocairo-1.0-0 libx11-xcb1 libxcb-shm0 \
libxcursor1 libxi6 libxrender1 libxtst6 libsoup-3.0-0 gstreamer1.0-libav gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good libegl1 libenchant-2-2 libepoxy0 \
libevdev2 libgles2 libglx0 libgstreamer-gl1.0-0 libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 libgudev-1.0-0 libharfbuzz-icu0 libhyphen0 libicu72 libjpeg62-turbo liblcms2-2 \
libmanette-0.2-0 libnotify4 libopengl0 libopenjp2-7 libopus0 libpng16-16 libproxy1v5 libsecret-1-0 libwayland-client0 libwayland-egl1 libwayland-server0 libwebp7 libwebpdemux2 \
libwoff1 libxml2 libxslt1.1 libatomic1 libevent-2.1-7

# Install ZVM - https://github.com/tristanisham/zvm
RUN curl --proto '=https' --tlsv1.3 -sSfL https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash
RUN echo "# ZVM" >> $HOME/.bashrc &&\
 echo export ZVM_INSTALL="$HOME/.zvm" >> $HOME/.bashrc &&\
 echo export PATH="\$PATH:\$ZVM_INSTALL/bin" >> $HOME/.bashrc &&\
 echo export PATH="\$PATH:\$ZVM_INSTALL/self" >> $HOME/.bashrc

# Install ZIG & ZLS
RUN $HOME/.zvm/self/zvm i -D=zls 0.12.0

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
RUN make clean-cache \
&& apt-get -y clean \
&& apt-get -y autoclean \
&& apt-get -y autoremove \
&& rm -rf /var/cache/apt/* \
&& rm -rf /var/lib/apt/lists/* \
&& rm -rf /var/cache/debconf/*-old \
&& rm -rf /usr/share/doc/* \
&& rm -rf /usr/share/man/?? \
&& rm -rf /usr/share/man/??_* \
&& rm -rf /tmp/*

FROM base as test-base
RUN make setup-playwright USE_NODE=1

FROM test-base as test
COPY . /root/dylanlangston.com/
RUN --network=host make build-web test USE_NODE=1

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
RUN make update-version VERSION=$VERSION release OPTIMIZE=$OPTIMIZE USE_NODE=1 PRECOMPRESS_RELEASE=$PRECOMPRESS_RELEASE

# Export files
FROM scratch AS publish
COPY --from=build /root/dylanlangston.com/site/build/ /site/build
COPY --from=build /root/dylanlangston.com/rust-lambda/target*/contact* /rust-lambda/target/contact
COPY --from=build /root/dylanlangston.com/rust-lambda/target*/email-forward* /rust-lambda/target/email-forward
COPY --from=build /root/dylanlangston.com/python-lambda/build/* /python-lambda/build

# Default Stage is the Base stage
FROM base as default
