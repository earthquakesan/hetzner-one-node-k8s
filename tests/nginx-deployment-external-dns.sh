#!/usr/bin/env bash
# This is a manual test

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
source $parent_path/variables.sh

export TEST_NS=nginx

kubectl create ns ${TEST_NS}
kubectl -n ${TEST_NS} create deployment nginx --image=nginx --replicas=1
kubectl -n ${TEST_NS} rollout status -w deployment/nginx
kubectl -n ${TEST_NS} create service clusterip nginx --tcp=80:80
kubectl -n ${TEST_NS} create ingress nginx --class=traefik --rule="nginx.${DOMAIN_NAME}/=nginx:80"
