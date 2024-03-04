FROM mcr.microsoft.com/devcontainers/base:debian as base

# Install General Dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends ca-certificates bash curl unzip xz-utils make git python3 glslang-tools nodejs npm

# Install Docker
RUN install -m 0755 -d /etc/apt/keyrings \
     && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
     && chmod a+r /etc/apt/keyrings/docker.asc \
     && echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     tee /etc/apt/sources.list.d/docker.list > /dev/null \
     && apt-get update && apt-get -y install --no-install-recommends docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Clean Image
RUN apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Important we change to the vscode user that the devcontainer runs under
USER vscode
WORKDIR /home/vscode

# Install ZVM - https://github.com/tristanisham/zvm
RUN curl --proto '=https' --tlsv1.3 -sSf https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash
RUN echo "# ZVM" >> $HOME/.bashrc
RUN echo export ZVM_INSTALL="$HOME/.zvm" >> $HOME/.bashrc
RUN echo export PATH="\$PATH:\$ZVM_INSTALL/bin" >> $HOME/.bashrc
RUN echo export PATH="\$PATH:\$ZVM_INSTALL/self" >> $HOME/.bashrc

# Install ZIG
RUN $HOME/.zvm/self/zvm i master

# Install ZLS
RUN $HOME/.zvm/self/zvm i -D=zls master

# Install rust
RUN curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | bash -s -- -y

# Install Cargo B(inary)Install
RUN curl -L --proto '=https' --tlsv1.3 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Install Cargo Lambda
RUN $HOME/.cargo/bin/cargo binstall cargo-lambda -y

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash