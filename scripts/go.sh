#!/bin/bash
set -euxo pipefail

cd /data/installer
./build.sh /p:ArcadeBuildTarball=true /p:TarballDir=/data/tb/$1 /p:PreserveTarballGitFolders=true

cd /data/tb/$1
./prep.sh
./build.sh --online
