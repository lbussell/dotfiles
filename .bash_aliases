#!/bin/bash

alias gs="git status"
alias ys="yadm status"
alias fpush="git push --force-with-lease"

FEDORA_33="mcr.microsoft.com/dotnet-buildtools/prereqs:fedora-33-20210222183538-031e7d2"
alias f33="podman run --rm -v .:/data -w /data $FEDORA_33"

GPG_TTY=$(tty)
export GPG_TTY
