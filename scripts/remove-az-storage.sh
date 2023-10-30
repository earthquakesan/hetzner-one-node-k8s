#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
source $parent_path/variables.sh

# Drop the whole resource group with storage account and everything else
set -x
az group delete -n ${RG_NAME}

# Remove service principal
SP_ID=$(az ad sp list --display-name ${SP_NAME} | jq .[].id -r)
az ad sp delete --id ${SP_ID}
