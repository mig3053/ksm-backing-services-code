#!/bin/bash

TERRAFORM="/var/lib/jenkins/libs/terraform-0.10.6"

# Lookup password in Vault
export VAULT_ADDR=https://vault-int.mckinsey-solutions.com
vault auth -method=aws role=${VAULT_ROLE}
CLUSTER_ID=${SOLUTION}-${K8S_ENVIRONMENT}-${TENANT_ID}-${INSTANCE_ID}

AUTH_TOKEN="$(vault read -field=auth_token ${VAULT_BACKEND}/${CLUSTER_NAME}/elasticache/${CLUSTER_ID})";

# Assume role into account
source ./aws_creds_env.sh

mkdir -p planned
cp templates/elasticache_redis.tf planned/elasticache_redis.tf
cd planned

cat <<EOF > backend.tf
terraform {
   backend "s3" {
   bucket = "${CLUSTER_NAME}-tfstate"
   key = "elasticache/${CLUSTER_ID}.tfstate"
   encrypt = "true"
   region = "${REGION}"
 }
}
EOF

export AWS_DEFAULT_REGION=${REGION}

${TERRAFORM} get
${TERRAFORM} init
${TERRAFORM} plan -var k8s_environment=${K8S_ENVIRONMENT} -var tenant_id=${TENANT_ID} -var cluster_name=${CLUSTER_NAME} -var solution_abbreviation=${SOLUTION} -var instance_id=${INSTANCE_ID} -var node_type=${NODE_TYPE} -var auth_token="$AUTH_TOKEN" -var number_cache_clusters=${NUMBER_CACHE_CLUSTERS} -var apply_immediately="$APPLY_IMMEDIATELY" -var maintenance_window=${MAINTENANCE_WINDOW} -var automatic_failover_enabled=${AUTOMATIC_FAILOVER_ENABLED} -out=planfile

if [ "$TERRAFORM_APPLY" == "true" ]
then
    ${TERRAFORM} apply planfile
    echo "-- Apply complete! Here are the outputs:"
    ${TERRAFORM} output
fi
