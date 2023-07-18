#!/usr/bin/env bash

set -ex

wget https://downloads.nestybox.com/sysbox/releases/v0.6.1/sysbox-ce_0.6.1-0.linux_amd64.deb

docker rm $(docker ps -a -q) -f

sudo apt-get install jq
sudo apt-get install ./sysbox-ce_0.6.1-0.linux_amd64.deb

sudo systemctl status sysbox -n20

set +ex
