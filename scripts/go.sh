#!/bin/bash
set -euxo pipefail

cd /data/installer
./build.sh /p:ArcadeBuildTarball=true /p:TarballDir=/data/$1 /p:PreserveTarballGitFolders=true

cd /data/$1
cp /data/psb-cache/Private* packages/archive/
./prep.sh
./build.sh --online