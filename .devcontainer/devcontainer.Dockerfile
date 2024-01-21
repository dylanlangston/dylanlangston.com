FROM mcr.microsoft.com/devcontainers/base:debian as base

RUN apt update && apt upgrade
RUN apt install -y bash curl unzip xz-utils make git python3
# Install ZVM - https://github.com/tristanisham/zvm
RUN curl https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash
ENV PATH="$HOME/.bun/bin/:$HOME/.zvm/self/:$HOME/.zvm/bin:$PATH"
RUN zvm i master
RUN zvm i -D=zls master
# Install Bun
RUN curl -fsSL https://bun.sh/install | bash