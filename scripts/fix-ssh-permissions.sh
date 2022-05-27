#!/bin/bash
set -euxo pipefail

sudo chown -R $USER:$USER ~/.ssh
sudo chmod 700 ~/.ssh
sudo chmod 600 ~/.ssh/authorized_keys
sudo chmod 400 ~/.ssh/id_*
sudo chmod 644 ~/.ssh/id_*.pub
sudo chmod 600 ~/.ssh/known_hosts
ssh -T git@github.com
