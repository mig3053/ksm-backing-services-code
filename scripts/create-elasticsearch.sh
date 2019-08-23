#!/bin/bash

TERRAFORM="/var/lib/jenkins/libs/terraform-0.10.6"

# Assume role into account
source ./aws_creds_env.sh

mkdir -p planned
cp templates/elasticsearch.tf planned/elasticsearch.tf
cd planned

ES_NAME="${SOLUTION}-${K8S_ENVIRONMENT}-${TENANT_ID}-${ELASTICSEARCH_NAME}"

cat <<EOF > backend.tf
terraform {
  backend "s3" {
    bucket = "${CLUSTER_NAME}-tfstate"
    key = "elasticsearch/${ES_NAME}.tfstate"
    encrypt = "true"
    region = "${REGION}"
  }
}
EOF

export AWS_DEFAULT_REGION=${REGION}

# Terraform variables
# cannot be passed on CLI due to a bug which parses some tenant IDs as numbers

# As Elasticsearch AWS managed service has some complex requirements, I'll hardcode two scenarios based 
# on AWS best practices and documentation to avoid adding to much complexity on the Terraform scripts

if [ "${K8S_ENVIRONMENT}" == "prod" ]; then
  export TF_VAR_dedicated_master_count="3"
  export TF_VAR_dedicated_master_enabled="true"
else
  export TF_VAR_dedicated_master_count="0"
  export TF_VAR_dedicated_master_enabled="false"
  export TF_VAR_zone_awareness_enabled="false"
fi

# Enable multizone when possible
if ! ((${INSTANCE_COUNT} % 2)); then
  export TF_VAR_zone_awareness_enabled="true"
else
  export TF_VAR_zone_awareness_enabled="false"
fi

export TF_VAR_automated_snapshot_start_hour=${AUTOMATED_SNAPSHOT_START_HOUR}
export TF_VAR_cluster_name=${CLUSTER_NAME}
export TF_VAR_elasticsearch_name=${ELASTICSEARCH_NAME}
export TF_VAR_elasticsearch_version=${ELASTICSEARCH_VERSION}
export TF_VAR_instance_count=${INSTANCE_COUNT}
export TF_VAR_instance_type=${INSTANCE_TYPE}
export TF_VAR_dedicated_master_type=${INSTANCE_TYPE}
export TF_VAR_k8s_environment=${K8S_ENVIRONMENT}
export TF_VAR_kms_key_name=${KMS_KEY_NAME}
export TF_VAR_solution=${SOLUTION}
export TF_VAR_tenant_id=${TENANT_ID}
export TF_VAR_volume_size=${VOLUME_SIZE}

${TERRAFORM} get
${TERRAFORM} init
${TERRAFORM} plan -out=planfile

if [ "$TERRAFORM_APPLY" == "true" ]
then
    ${TERRAFORM} apply planfile
    ${TERRAFORM} output
fi