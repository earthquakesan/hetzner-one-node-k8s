#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
source $parent_path/variables.sh

echo "this script will create Azure storage account for terraform state"
echo "in case if storage account already exist the script will simply exit"

# Create resource group for the azure storage
IS_GROUP_EXIST=$(az group exists -n ${RG_NAME})

if [ $IS_GROUP_EXIST = "false" ]; then
    echo "Resource group ${RG_NAME} does not exist, creating..."
    az group create -l ${REGION} -n ${RG_NAME}
else
    echo "Resource group ${RG_NAME} already exist, skipping creation..."
fi

# Create storage account
IS_STORAGE_ACCOUNT_NAME_AVAILABLE=$(az storage account check-name -n ${STORAGE_ACCOUNT_NAME} | jq .nameAvailable -r)
if [ $IS_STORAGE_ACCOUNT_NAME_AVAILABLE = "true" ]; then
    echo "Storage account name ${STORAGE_ACCOUNT_NAME} is available, creating..."
    az storage account create -n ${STORAGE_ACCOUNT_NAME} -g ${RG_NAME}
else
    echo "Storage account name ${STORAGE_ACCOUNT_NAME} is not available, skipping creation..."
fi

# Create container
IS_STORAGE_CONTAINER_EXIST=$(az storage container exists --account-name ${STORAGE_ACCOUNT_NAME} -n ${STORAGE_CONTAINER_NAME} --auth-mode login | jq .exists)

if [ $IS_STORAGE_CONTAINER_EXIST = "false" ]; then
    echo "Storage container ${STORAGE_CONTAINER_NAME} in ${STORAGE_ACCOUNT_NAME} storage account does not exist, creating..."
    az storage container create --account-name ${STORAGE_ACCOUNT_NAME} -n ${STORAGE_CONTAINER_NAME} --auth-mode login
else
    echo "Storage container ${STORAGE_CONTAINER_NAME} in ${STORAGE_ACCOUNT_NAME} exists, skipping creation..."
fi

# Create service principal for access to the storage account
STORAGE_ACCOUNT_ID=$(az storage account show -n k3shetznertfsa | jq .id -r)

echo "Creating service principal for ${STORAGE_ACCOUNT_ID} resource with name ${SP_NAME} and role ${SP_ROLE}"
SP_INFO=$(az ad sp create-for-rbac -n ${SP_NAME} --role ${SP_ROLE} --scopes ${STORAGE_ACCOUNT_ID})

cat <<EOF > $parent_path/../.env
export ARM_CLIENT_ID=$(echo $SP_INFO | jq .appId -r)
export ARM_CLIENT_SECRET=$(echo $SP_INFO | jq .password -r)
export ARM_TENANT_ID=$(echo $SP_INFO | jq .tenant -r)
export ARM_SUBSCRIPTION_ID=$(az account show | jq .id -r)
EOF
