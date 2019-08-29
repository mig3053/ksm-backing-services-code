#!/bin/bash

TERRAFORM="/var/lib/jenkins/libs/terraform-0.10.6"


# Assume role into account
#source ./aws_creds_env.sh
echo "Kawaljit Starting ..."
mkdir -p planned
cp templates/s3.tf planned/s3.tf
cd planned

cat <<EOF > backend.tf
terraform {
   backend "s3" {
   bucket = "${CLUSTER_NAME}-tfstate"
   key = "s3/${SOLUTION}-${BUCKET_NAME}.tfstate"
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
export TF_VAR_tenant_id=${TENANT_ID}
export TF_VAR_kms_key_name=${KMS_KEY_NAME}
export TF_VAR_k8s_environment=${K8S_ENVIRONMENT}
export TF_VAR_bucket_name=${BUCKET_NAME}

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
