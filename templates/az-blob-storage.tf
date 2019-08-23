variable "cluster_name" {}
variable "environment" {}
variable "subscription" {}
variable "solution" {}
variable "tenant" {}
variable "ip_whitelist" {
  type = "list"
}
variable "region" {
  default = "eastus2"
}
variable "tier" {}
variable "replication" {}
variable "resource_group_name" {}
variable "instance_name" {}

module "storage" {
  source                       = "../terraform/azr_blob_storage"
  cluster_name = "${var.cluster_name}"
  environment = "${var.environment}"
  subscription = "${var.subscription}"
  solution = "${var.solution}"
  tenant = "${var.tenant}"
  ip_whitelist = "${var.ip_whitelist}"
  region = "${var.region}"
  tier = "${var.tier}"
  replication = "${var.replication}"
  resource_group_name = "${var.resource_group_name}"
  instance_name = "${var.instance_name}"
}

output "resource_group_name" {
  value = "${module.storage.resource_group_name}"
}

output "storage_account_name" {
  value = "${module.storage.storage_account_name}"
}

output "access_key" {
  value = "${module.storage.access_key}"
  sensitive = true
}
