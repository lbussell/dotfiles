#!/bin/bash

export VISUAL=vim
export EDITOR="$VISUAL"

alias g="git status"
alias gs="git status"
alias ys="yadm status"
alias fpush="git push --force-with-lease"

alias sls="screen -ls"
alias ss="screen -S"
alias sr="screen -r"

TARBALL_DIR="/data/vcs/lbussell/tarballs/"

alias darc="/home/logan/.dotnet/tools/darc"

FEDORA_33="mcr.microsoft.com/dotnet-buildtools/prereqs:fedora-33-20210222183538-031e7d2"
alias f33="podman run --rm -v .:/data -w /data $FEDORA_33"

DEBIAN_9="mcr.microsoft.com/dotnet-buildtools/prereqs:debian-stretch-bfcd90a-20200121150012"
alias d9="podman run --rm -v .:/data -w /data $DEBIAN_9"

CENTOS_7="mcr.microsoft.com/dotnet-buildtools/prereqs:centos-7-3e800f1-20190501005343"
alias c7="podman run --rm -v .:/data -w /data $CENTOS_7"

GPG_TTY=$(tty)
export GPG_TTY

set -o vi
