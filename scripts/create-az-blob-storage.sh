#!/bin/bash

TERRAFORM="/var/lib/jenkins/libs/terraform-0.10.6"
AZ="docker run -t --rm -v $PWD/planned:/workdir -v $PWD/home:/root quay.mckinsey-solutions.com/nvt-platform/azure_toolbox:0.9.1 az"

# Get Service Principal
export VAULT_ADDR=https://vault-int.mckinsey-solutions.com
if [ "${BRANCH}" == "prod" ]; then
  export SP_VAULT_BACKEND=mckube-prod
  vault auth -method=aws role=mckube-prod-rw-jenkins-mke
else
  export SP_VAULT_BACKEND=mckube-npn
  vault auth -method=aws role=mckube-npn-rw-jenkins-mke
fi

eval $(vault read -field=value ${SP_VAULT_BACKEND}/azure/${SUBSCRIPTION}/terraform-service-principal)
echo "Subscription ID: $ARM_SUBSCRIPTION_ID"
echo "Client ID: $ARM_CLIENT_ID"
echo "Tenant ID: $ARM_TENANT_ID"
export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID
export ARM_CLIENT_ID=$ARM_CLIENT_ID
export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
export ARM_TENANT_ID=$ARM_TENANT_ID

HASH=$(echo "${SUBSCRIPTION}eastus" | shasum | head -c 10 | awk '{print tolower($0)}'; echo)
STORAGEACCOUNTNAME="$(echo $SUBSCRIPTION | sed -e 's/-//g')basesa$HASH"

if [ "$RESOURCE_GROUP_NAME" == "" ]; then
    RESOURCE_GROUP_NAME="${SOLUTION}-${ENVIRONMENT}-${TENANT_ID}"
fi

mkdir -p planned home
cp templates/az-blob-storage.tf planned/az-blob-storage.tf
cd planned

cat <<EOF > backend.tf
provider "azurerm" {
  version = "1.8.0"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "${SUBSCRIPTION}-base-rg"
    storage_account_name = "${STORAGEACCOUNTNAME:0:24}"
    container_name       = "terraform"
    key                  = "storage-${SOLUTION}-${ENVIRONMENT}-${TENANT_ID}-${INSTANCE_ID}.tfstate"
  }
}
EOF

# Terraform variables
# cannot be passed on CLI due to a bug which parses some tenant IDs as numbers
export TF_VAR_solution=${SOLUTION}
export TF_VAR_environment=${ENVIRONMENT}
export TF_VAR_subscription=${SUBSCRIPTION}
export TF_VAR_cluster_name=${CLUSTER_NAME}
export TF_VAR_tenant=${TENANT_ID}
export TF_VAR_ip_whitelist=${IP_WHITELIST}
export TF_VAR_region=${REGION}
export TF_VAR_tier=${TIER}
export TF_VAR_replication=${REPLICATION}
export TF_VAR_resource_group_name=${RESOURCE_GROUP_NAME}
export TF_VAR_instance_name=${INSTANCE_ID}


${TERRAFORM} get
${TERRAFORM} init
${TERRAFORM} plan -out=planfile

if [ "$TERRAFORM_APPLY" == "true" ]
then
    ${TERRAFORM} apply planfile
    ${TERRAFORM} output
    OUTPUT=$(${TERRAFORM} output -json)
    RG_NAME=$(echo $OUTPUT | jq -r '.resource_group_name.value')
    SA_NAME=$(echo $OUTPUT | jq -r '.storage_account_name.value')

    KEY_HOST=$(echo "${ENCRYPTION_KEY_URI}" | awk -F"/" '{print $3}')
    KEY_NAME=$(echo "${ENCRYPTION_KEY_URI}" | awk -F"/" '{print $5}')
    KEY_VERSION=$(echo "${ENCRYPTION_KEY_URI}" | awk -F"/" '{print $6}')
    KEY_VAULT_NAME=$(echo "${KEY_HOST}" | awk -F"." '{print $1}')


    echo "Enabling BYOK/CMK encryption..."
    ${AZ} login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID --query '""'
    ${AZ} account set --subscription $ARM_SUBSCRIPTION_ID
    PRINCIPAL_ID=$(${AZ} storage account update -g "$RG_NAME" -n "$SA_NAME"  --assign-identity --output tsv --query 'identity.principalId')
    PRINCIPAL_ID=$(echo $PRINCIPAL_ID | tr -d '$' | tr -d "'" | tr -d '\r')
    ${AZ} keyvault update -n ${KEY_VAULT_NAME} -g "${SUBSCRIPTION}-${CLUSTER_NAME}-${ENVIRONMENT}-cluster-rg" --set ".properties.additionalProperties.enablePurgeProtection=true" --set ".properties.enableSoftDelete=true"
    ${AZ} keyvault set-policy -n ${KEY_VAULT_NAME} -g "${SUBSCRIPTION}-${CLUSTER_NAME}-${ENVIRONMENT}-cluster-rg" --object-id "${PRINCIPAL_ID}" --key-permissions wrapkey unwrapkey get
    ${AZ} storage account update -g "$RG_NAME" -n "$SA_NAME" --encryption-key-source="Microsoft.Keyvault" --set ".encryption.keyVaultProperties.keyName=${KEY_NAME}" --set ".encryption.keyVaultProperties.keyVaultUri=https://${KEY_HOST}/" --set ".encryption.keyVaultProperties.keyVersion=${KEY_VERSION}"
fi
