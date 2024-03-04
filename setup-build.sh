#!/bin/bash

# This script is intended to setup the docker/github action build environment. 

# Update and Install Deps
apt-get update && apt-get -y install --no-install-recommends ca-certificates bash curl unzip xz-utils make git python3

# Make Setup
make clean-cache setup USE_NODE=1

# Install Node
apt-get -y install --no-install-recommends nodejs npm

# Clean temp files
apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

# Install Bun
#curl -fsSL https://bun.sh/install | bash

# Install rust
curl --proto '=https' --tlsv1.3 -sSf https://sh.rustup.rs | bash -s -- -y

# Install Cargo B(inary)Install
curl -L --proto '=https' --tlsv1.3 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

# Install Cargo Lambda
$HOME/.cargo/bin/cargo binstall cargo-lambda -y

# Install ZVM - https://github.com/tristanisham/zvm
cur -L --proto '=https' --tlsv1.3 -sSf https://raw.githubusercontent.com/tristanisham/zvm/master/install.sh | bash
echo "# ZVM" >> $HOME/.bashrc
echo export ZVM_INSTALL="$HOME/.zvm" >> $HOME/.bashrc
echo export PATH="\$PATH:\$ZVM_INSTALL/bin" >> $HOME/.bashrc
echo export PATH="\$PATH:\$ZVM_INSTALL/self" >> $HOME/.bashrc

# Install ZIG
$HOME/.zvm/self/zvm i master

# Install ZLS
$HOME/.zvm/self/zvm i -D=zls master

# Update PATH
. $HOME/.bashrc

# Check that path was updated
zig version
cargo version