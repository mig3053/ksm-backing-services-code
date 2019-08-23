variable "solution" {}
variable "bucket_name" {}
variable "k8s_environment" {}
variable "cluster_name" {}
variable "kms_key_name" {}
variable "tenant_id" {}

module "s3" {
  source          = "../terraform/s3"
  bucket_name     = "${var.bucket_name}"
  solution        = "${var.solution}"
  k8s_environment = "${var.k8s_environment}"
  cluster_name    = "${var.cluster_name}"
  kms_key_name    = "${var.kms_key_name}"
  tenant_id       = "${var.tenant_id}"
}

output "bucket_name" {
  value = "${module.s3.bucket_name}"
}

output "account_id" {
  value = "${module.s3.account_id}"
}

output "caller_arn" {
  value = "${module.s3.caller_arn}"
}

output "caller_user" {
  value = "${module.s3.caller_user}"
}
