#!/usr/bin/env bash

IP_ADDRESS=$(terraform -chdir=deployment/terraform/cluster output -raw ip_address)
ssh -o StrictHostKeyChecking=no root@${IP_ADDRESS}

kubectl wait --for=condition=Ready node/k3s-main

# Install argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
