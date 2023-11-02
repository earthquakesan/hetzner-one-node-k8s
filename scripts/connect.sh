#!/usr/bin/env bash

IP_ADDRESS=$(terraform -chdir=deployment/terraform/cluster output -raw ip_address)
ssh -o StrictHostKeyChecking=no root@${IP_ADDRESS}
