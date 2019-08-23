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
