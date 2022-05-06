#!/bin/bash
git clone git@github.com:lbussell/$1.git
cd $1
git remote add upstream https://github.com/dotnet/installer.git
git fetch upstream
