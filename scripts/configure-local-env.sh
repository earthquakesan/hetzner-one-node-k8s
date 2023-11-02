#!/usr/bin/env bash

YAML_CONFIG_PATH=/etc/rancher/k3s/k3s.yaml

IP_ADDRESS=$(terraform -chdir=deployment/terraform/cluster output -raw ip_address)
scp -o StrictHostKeyChecking=no root@${IP_ADDRESS}:${YAML_CONFIG_PATH} ./.kube/

sed -i "s/127\.0\.0\.1/${IP_ADDRESS}/g" ./.kube/k3s.yaml
echo "export KUBECONFIG=${PWD}/.kube/k3s.yaml"
