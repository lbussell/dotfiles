#!/bin/bash

sudo apt-get update

# tools
sudo apt-get install -y \
    git \
    nodejs \
    npm \
    tar \
    jq \
    zip

# dependencies for runtime, mono, corefx, etc.
sudo apt-get install -y \
    autoconf \
    automake \
    build-essential \
    gettext \
    libcurl4-openssl-dev \
    libgdiplus \
    libicu-dev \
    libkrb5-dev \
    liblttng-ust-dev \
    libnuma-dev \
    libssl-dev \
    libtool \
    libunwind8 \
    libunwind8-dev \
    python3 \
    uuid-dev

# github CLI
dpkg -l "gh"
if [ $? = '1' ]
then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh
fi

