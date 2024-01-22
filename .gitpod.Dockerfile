FROM gitpod/workspace-full:latest as base

RUN sudo apt-get update \
     && sudo apt-get -y install --no-install-recommends bash curl unzip xz-utils make git python3 \
     && sudo apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Important we change to the gitpod user that the devcontainer runs under
USER gitpod
WORKDIR /home/gitpod

# Install ZVM - https://github.com/tristanisham/zvm
RUN curl https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash
RUN echo "# ZVM" >> $HOME/.bashrc
RUN echo export ZVM_INSTALL="$HOME/.zvm" >> $HOME/.bashrc
RUN echo export PATH="\$PATH:\$ZVM_INSTALL/bin" >> $HOME/.bashrc
RUN echo export PATH="\$PATH:\$ZVM_INSTALL/self" >> $HOME/.bashrc

# Install ZIG
RUN $HOME/.zvm/self/zvm i master

# Install ZLS
RUN $HOME/.zvm/self/zvm i -D=zls master

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash