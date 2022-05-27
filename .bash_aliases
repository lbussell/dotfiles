#!/bin/bash

export VISUAL=vim
export EDITOR="$VISUAL"

alias l="ls -lah"
alias ll="ls -lah"

alias g="git status"
alias gs="git status"
alias ga="git add"
alias ys="yadm status"
alias ya="yadm add"
alias fpush="git push --force-with-lease"

alias sls="screen -ls"
alias ss="screen -S"
alias sr="screen -r"

alias darc="/home/logan/.dotnet/tools/darc"

export FEDORA_31="mcr.microsoft.com/dotnet-buildtools/prereqs:fedora-31-02f7c7e-20200324132728"
alias f31="podman run --rm -v .:/data -w /data $FEDORA_31"

export FEDORA_33="mcr.microsoft.com/dotnet-buildtools/prereqs:fedora-33-20210222183538-031e7d2"
alias f33="podman run --rm -v .:/data -w /data $FEDORA_33"

export FEDORA_34="mcr.microsoft.com/dotnet-buildtools/prereqs:fedora-34-20211118185932-9355e7b"
alias f34="podman run --rm -v .:/data -w /data $FEDORA_34"

export DEBIAN_9="mcr.microsoft.com/dotnet-buildtools/prereqs:debian-stretch-bfcd90a-20200121150012"
alias d9="podman run --rm -v .:/data -w /data $DEBIAN_9"

export CENTOS_7="mcr.microsoft.com/dotnet-buildtools/prereqs:centos-7-3e800f1-20190501005343"
alias c7="podman run --rm -v .:/data -w /data $CENTOS_7"

CENTOS_8="mcr.microsoft.com/dotnet-buildtools/prereqs:centos-8-source-build-20211118190102-9355e7b"
export CENTOS_8="mcr.microsoft.com/dotnet-buildtools/prereqs:centos-8-source-build-20200402192642-9e679d4"
alias c8="podman run --rm -v .:/data -w /data $CENTOS_8"

export PSB_ARCHIVE="/home/logan/vcs/Private.SourceBuilt.Artifacts.7.0.103.tar.gz"

docker-run() {
    docker run -it --rm -v $(pwd):/data -w /data "$1"
}

podman-run() {
    podman run -it --rm -v $(pwd):/data -w /data "$1"
}

cdl() {
    cd "$1";
    ls -lah;
}

GPG_TTY=$(tty)
export GPG_TTY

export DOTNET_ROOT=$HOME/dotnet
export PATH=$PATH:$HOME/dotnet

export SB_ARGS='-c Release --restore --build --pack /p:ArcadeBuildFromSource=true -bl'
