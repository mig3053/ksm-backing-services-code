#!/bin/bash

TERRAFORM="/var/lib/jenkins/libs/terraform-0.10.6"

# Lookup password in Vault
export VAULT_ADDR=https://vault-int.mckinsey-solutions.com
vault auth -method=aws role=${VAULT_ROLE}
CLUSTER_ID=${SOLUTION}-${K8S_ENVIRONMENT}-${TENANT_ID}-${INSTANCE_ID}

MASTER_PASSWORD=$(vault read -field=master_password ${VAULT_BACKEND}/${CLUSTER_NAME}/redshift/${CLUSTER_ID})

# Assume role into account
source ./aws_creds_env.sh

mkdir -p planned
cp templates/redshift.tf planned/redshift.tf
cd planned

cat <<EOF > backend.tf
terraform {
   backend "s3" {
   bucket = "${CLUSTER_NAME}-tfstate"
   key = "redshift/${CLUSTER_ID}.tfstate"
   encrypt = "true"
   region = "${REGION}"
 }
}
EOF

export AWS_DEFAULT_REGION=${REGION}

${TERRAFORM} get
${TERRAFORM} init
${TERRAFORM} plan -var k8s_environment=${K8S_ENVIRONMENT} -var tenant_id=${TENANT_ID} -var cluster_name=${CLUSTER_NAME} -var solution_abbreviation=${SOLUTION} -var instance_id=${INSTANCE_ID} -var database_name=${DATABASE_NAME} -var master_username=${MASTER_USERNAME} -var master_password=${MASTER_PASSWORD} -var cluster_type=${CLUSTER_TYPE} -var node_type=${NODE_TYPE} -var number_of_nodes=${NUMBER_OF_NODES} -var iam_roles=${IAM_ROLES} -var kms_key_name=${KMS_KEY_NAME} -var snapshot_retention_period=${SNAPSHOT_RETENTION_PERIOD} -var maintenance_window=${MAINTENANCE_WINDOW} -out=planfile

if [ "$TERRAFORM_APPLY" == "true" ]
then
    ${TERRAFORM} apply planfile
    echo "-- Apply complete! Here are the outputs:"
    ${TERRAFORM} output
fi
# IF chosen to apply
# THEN terraform apply planfile
