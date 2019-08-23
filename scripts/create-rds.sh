#!/bin/bash

TERRAFORM="/var/lib/jenkins/libs/terraform-0.10.6"

# Lookup password in Vault
export VAULT_ADDR=https://vault-int.mckinsey-solutions.com
vault auth -method=aws role=${VAULT_ROLE}
RDS_NAME=${SOLUTION}-${K8S_ENVIRONMENT}-${TENANT_ID}-${DB_ENGINE}-${INSTANCE_ID}

MASTER_PASSWORD=$(vault read -field=master_password ${VAULT_BACKEND}/${VAULT_PATH})

# Assume role into account
source ./aws_creds_env.sh

mkdir -p planned
cp templates/rds.tf planned/rds.tf
cd planned

cat <<EOF > backend.tf
provider "aws" {
  version = "~> 1.60"
  region = "${REGION}"
}

terraform {
   backend "s3" {
   bucket = "${CLUSTER_NAME}-tfstate"
   key = "rds/${RDS_NAME}.tfstate"
   encrypt = "false"
   region = "${REGION}"
 }
}
EOF

export AWS_DEFAULT_REGION=${REGION}

# Terraform variables
# cannot be passed on CLI due to a bug which parses some tenant IDs as numbers
export TF_VAR_cluster_name=${CLUSTER_NAME}
export TF_VAR_solution=${SOLUTION}
export TF_VAR_db_name=${DB_NAME}
export TF_VAR_tenant_id=${TENANT_ID}
export TF_VAR_kms_key_name=${KMS_KEY_NAME}
export TF_VAR_master_username=${MASTER_USERNAME}
export TF_VAR_master_password=${MASTER_PASSWORD}
export TF_VAR_allocated_storage=${ALLOCATED_STORAGE}
export TF_VAR_backup_retention_period=${BACKUP_RETENTION_PERIOD}
export TF_VAR_engine=${DB_ENGINE}
export TF_VAR_engine_version=${DB_ENGINE_VERSION}
export TF_VAR_instance_class=${INSTANCE_CLASS}
export TF_VAR_storage_class=${STORAGE_CLASS}
export TF_VAR_k8s_environment=${K8S_ENVIRONMENT}
export TF_VAR_multi_az=${MULTI_AZ}
export TF_VAR_instance_id=${INSTANCE_ID}

${TERRAFORM} get
${TERRAFORM} init
${TERRAFORM} plan -out=planfile

if [ "$TERRAFORM_APPLY" == "true" ]
then
    ${TERRAFORM} apply planfile
    ${TERRAFORM} output
fi
# IF chosen to apply
# THEN terraform apply planfile
