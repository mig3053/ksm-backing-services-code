#!/bin/bash

TERRAFORM="/var/lib/jenkins/libs/terraform-0.10.6"

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

# Lookup password in Vault
export VAULT_ADDR=https://vault-int.mckinsey-solutions.com
vault auth -method=aws role=${VAULT_ROLE}
AZ_NAME=${SOLUTION}-${K8S_ENVIRONMENT}-${TENANT_ID}-${INSTANCE_ID}

if [ "$MASTER_PASSWORD" == "" ]; then
    if vault read ${VAULT_BACKEND}/${CLUSTER_NAME}/azure/postgres/${AZ_NAME}; then
        MASTER_PASSWORD=$(vault read -field=master_password ${VAULT_BACKEND}/${CLUSTER_NAME}/azure/postgres/${AZ_NAME})
    fi
fi

if [ "$MASTER_PASSWORD" == "" ]; then
    MASTER_PASSWORD=$(openssl rand -base64 32)
fi

vault write ${VAULT_BACKEND}/${CLUSTER_NAME}/azure/postgres/${AZ_NAME} master_password=${MASTER_PASSWORD}

# Derive SKU
if [ "$SKU_TIER" == "Basic" ]; then
    SKU_CODE="B"
    GR_BACKUP="Disabled"
elif [ "$SKU_TIER" == "GeneralPurpose" ]; then
    SKU_CODE="GP"
    GR_BACKUP="Enabled"
elif [ "$SKU_TIER" == "MemoryOptimized" ]; then
    SKU_CODE="MO"
    GR_BACKUP="Enabled"
else
    echo "Unknown SKU_TIER $SKU_TIER"
    exit 1
fi

SKU_NAME="${SKU_CODE}_${SKU_FAMILY}_${SKU_CAPACITY}"
STORAGE=$(expr $ALLOCATED_STORAGE \* 1024)

mkdir -p planned
cp templates/az-postgres.tf planned/az-postgres.tf
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
    key                  = "postgres-${AZ_NAME}.tfstate"
  }
}
EOF

# Terraform variables
# cannot be passed on CLI due to a bug which parses some tenant IDs as numbers
export TF_VAR_solutionName=${SOLUTION}
export TF_VAR_environment=${K8S_ENVIRONMENT}
export TF_VAR_clusterName=${CLUSTER_NAME}
export TF_VAR_tenantId=${TENANT_ID}
export TF_VAR_rgName=${SOLUTION}-${K8S_ENVIRONMENT}-${TENANT_ID}-${INSTANCE_ID}
export TF_VAR_location=${REGION}
export TF_VAR_PGsku="{ name = \"${SKU_NAME}\", capacity = \"${SKU_CAPACITY}\", tier = \"${SKU_TIER}\", family = \"${SKU_FAMILY}\" }"
export TF_VAR_PGstorageProfile="{ storage_mb = \"${STORAGE}\", backup_retention_days = \"${BACKUP_RETENTION_PERIOD}\", geo_redundant_backup = \"${GR_BACKUP}\" }"
export TF_VAR_PGadminName=${MASTER_USERNAME}
export TF_VAR_PGversion=${ENGINE_VERSION}
export TF_VAR_PGpassword=${MASTER_PASSWORD}
export TF_VAR_PGdbNames="${DB_NAMES}"
export TF_VAR_PGcharset=${CHARSET}
export TF_VAR_PGcollation=${COLLATION}
export TF_VAR_sourceIPs=${SOURCE_IPS}
export TF_VAR_azDbName=${AZ_NAME}


${TERRAFORM} get
${TERRAFORM} init
${TERRAFORM} plan -out=planfile

if [ "$TERRAFORM_APPLY" == "true" ]
then
    ${TERRAFORM} apply planfile
    ${TERRAFORM} output
fi
