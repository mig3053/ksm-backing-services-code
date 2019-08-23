variable "solution" {}
variable "db_name" {}
variable "master_username" {}
variable "master_password" {}
variable "allocated_storage" {}
variable "backup_retention_period" {}
variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
variable "storage_class" {}
variable "k8s_environment" {}
variable "multi_az" {}
variable "cluster_name" {}
variable "kms_key_name" {}
variable "tenant_id" {}
variable "instance_id" {}

module "rds" {
  source                       = "../terraform/rds"
  solution_abbreviation        = "${var.solution}"
  db_name                      = "${var.db_name}"
  db_master_username           = "${var.master_username}"
  db_master_password_plaintext = "${var.master_password}"
  allocated_storage            = "${var.allocated_storage}"
  backup_retention_period      = "${var.backup_retention_period}"
  engine                       = "${var.engine}"
  engine_version               = "${var.engine_version}"
  instance_class               = "${var.instance_class}"
  storage_type                 = "${var.storage_class}"
  k8s_environment              = "${var.k8s_environment}"
  multi_az                     = "${var.multi_az}"
  cluster_name                 = "${var.cluster_name}"
  kms_key_name                 = "${var.kms_key_name}"
  tenant_id                    = "${var.tenant_id}"
  instance_id                  = "${var.instance_id}"
}

output "db_hostname" {
  value = "${module.rds.db_hostname}"
}
