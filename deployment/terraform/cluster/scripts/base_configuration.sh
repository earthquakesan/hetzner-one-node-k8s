#!/usr/bin/env bash

echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
systemctl restart ssh

curl -sfL https://get.k3s.io | sh -

kubectl wait --for=condition=Ready node/k3s-main
