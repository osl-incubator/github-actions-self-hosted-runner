#!/usr/bin/env bash

sudo mkdir -p /var/log
sudo chmod 777 /var/log

sudo dockerd > /var/log/dockerd.log 2>&1 &

sleep 1

cat /var/log/dockerd.log

$@
