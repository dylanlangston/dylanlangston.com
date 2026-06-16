FROM mcr.microsoft.com/devcontainers/base:debian as base

# Install general dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
      && apt-get -y install --no-install-recommends \
         ca-certificates bash curl unzip xz-utils make git \
         glslang-tools awscli pkg-config netcat-traditional zip git-lfs \
         build-essential procps

# Install Docker
RUN install -m 0755 -d /etc/apt/keyrings \
     && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
     && chmod a+r /etc/apt/keyrings/docker.asc \
     && echo \
     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
     $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
     tee /etc/apt/sources.list.d/docker.list > /dev/null \
     && apt-get update && apt-get -y install --no-install-recommends \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Allow vscode user to run docker commands without sudo
RUN usermod -aG docker vscode

# Install AWS SAM CLI
RUN curl -L "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o sam.zip \
     && unzip sam.zip -d ./sam \
     && rm sam.zip \
     && ./sam/install \
     && rm -rf ./sam

# Clean image
RUN apt-get clean \
     && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

# Switch to the vscode user that the devcontainer runs under
USER vscode
WORKDIR /home/vscode

# Install ZVM - https://github.com/tristanisham/zvm
RUN curl --proto '=https' --tlsv1.3 -sSfL \
      https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash \
     && echo "# ZVM" >> $HOME/.bashrc \
     && echo 'export ZVM_INSTALL="$HOME/.zvm"' >> $HOME/.bashrc \
     && echo 'export PATH="$PATH:$ZVM_INSTALL/bin"' >> $HOME/.bashrc \
     && echo 'export PATH="$PATH:$ZVM_INSTALL/self"' >> $HOME/.bashrc

# Install Zig and ZLS (master / nightly)
RUN $HOME/.zvm/self/zvm i --zls master

# Install Rust
RUN curl --proto '=https' --tlsv1.3 -sSfL https://sh.rustup.rs | bash -s -- -y \
     && $HOME/.cargo/bin/rustup target add aarch64-unknown-linux-gnu

# Install cargo-binstall and cargo-lambda
RUN curl --proto '=https' --tlsv1.3 -sSfL \
      https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash \
     && $HOME/.cargo/bin/cargo binstall cargo-lambda -y

# Install UV and Python 3.11
RUN curl -L --proto '=https' --tlsv1.3 -sSf https://astral.sh/uv/install.sh | sh \
     && $HOME/.local/bin/uv python install --default python3.11

# Install NVM and Node.js LTS (stable, well-supported release line)
RUN curl --proto '=https' --tlsv1.3 -sSfL \
      https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
     && bash -c "source $HOME/.nvm/nvm.sh && nvm install --lts && nvm use --lts"

# Install Bun
RUN curl -L --proto '=https' --tlsv1.3 -sSf https://bun.sh/install | bash

# Install DevTunnels
RUN curl -sL https://aka.ms/DevTunnelCliInstall | bash

# Initialise Git LFS
RUN git lfs install