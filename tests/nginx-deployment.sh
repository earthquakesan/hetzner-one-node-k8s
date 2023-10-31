#!/usr/bin/env bash
# This is a manual test

kubectl create deployment nginx --image=nginx --replicas=1
kubectl rollout status -w deployment/nginx
kubectl create service clusterip nginx --tcp=80:80
kubectl create ingress catch-all --class=traefik --rule="/=nginx:80"

echo "37.27.21.160 nginx.example.com" >> /etc/hosts
curl nginx.example.com

# Check the logs for the nginx container - there should be incoming request there
