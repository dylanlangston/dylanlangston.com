FROM gitpod/workspace-base:latest as base

# Install General Dependencies
RUN sudo apt-get update \
     && sudo apt-get -y install --no-install-recommends ca-certificates bash curl unzip xz-utils make git python3 glslang-tools nodejs npm awscli pkg-config \
     && sudo apt-get clean && sudo rm -rf /var/cache/apt/* && sudo rm -rf /var/lib/apt/lists/* && sudo rm -rf /tmp/*

# Install AWS SAM CLI
RUN curl -L "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip" -o sam.zip
RUN unzip sam.zip -d ./sam
RUN rm sam.zip
RUN sudo ./sam/install
RUN rm -rf ./sam

# Important we change to the gitpod user that the devcontainer runs under
USER gitpod
WORKDIR /home/gitpod

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
RUN rustup target add aarch64-unknown-linux-gnu

# Install Cargo B(inary)Install
RUN curl -L --proto '=https' --tlsv1.3 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Install Cargo Lambda
RUN cargo binstall cargo-lambda -y

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash