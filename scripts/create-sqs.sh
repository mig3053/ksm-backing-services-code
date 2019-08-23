#!/bin/bash

TERRAFORM="/var/lib/jenkins/libs/terraform-0.10.6"

# Assume role into account
source ./aws_creds_env.sh

mkdir -p planned
cp templates/sqs.tf planned/sqs.tf
cd planned

QUEUE_NAME="${SOLUTION}-${K8S_ENVIRONMENT}-${TENANT_ID}-${QUEUE_ID}"

cat <<EOF > backend.tf
terraform {
   backend "s3" {
   bucket = "${CLUSTER_NAME}-tfstate"
   key = "sqs/${QUEUE_NAME}.tfstate"
   encrypt = "true"
   region = "${REGION}"
 }
}
EOF

export AWS_DEFAULT_REGION=${REGION}

# Terraform variables
# cannot be passed on CLI due to a bug which parses some tenant IDs as numbers
export TF_VAR_cluster_name=${CLUSTER_NAME}
export TF_VAR_content_based_deduplication=${CONTENT_BASED_DEDUPLICATION}
export TF_VAR_delay_seconds=${DELAY_SECONDS}
export TF_VAR_fifo_queue=${FIFO_QUEUE}
export TF_VAR_k8s_environment=${K8S_ENVIRONMENT}
export TF_VAR_kms_data_key_reuse_period_seconds=${KMS_DATA_KEY_REUSE_PERIOD_SECONDS}
export TF_VAR_kms_key_name=${KMS_KEY_NAME}
export TF_VAR_max_message_size=${MAX_MESSAGE_SIZE}
export TF_VAR_message_retention_seconds=${MESSAGE_RETENTION_SECONDS}
export TF_VAR_queue_id=${QUEUE_ID}
export TF_VAR_receive_wait_time_seconds=${RECEIVE_WAIT_TIME_SECONDS}
export TF_VAR_solution=${SOLUTION}
export TF_VAR_tenant_id=${TENANT_ID}
export TF_VAR_visibility_timeout_seconds=${VISIBILITY_TIMEOUT_SECONDS} 

${TERRAFORM} get
${TERRAFORM} init
${TERRAFORM} plan -out=planfile

if [ "$TERRAFORM_APPLY" == "true" ]
then
    ${TERRAFORM} apply planfile
    ${TERRAFORM} output
fi