variable "k8s_environment" { }
variable "tenant_id" { }
variable "cluster_name" { }
variable "solution_abbreviation" { }
variable "instance_id" { }
variable "database_name" { }
variable "master_username" { }
variable "master_password" { }
variable "cluster_type" { }
variable "node_type" { }
variable "number_of_nodes" { }
variable "iam_roles" { }
variable "kms_key_name" { }
variable "snapshot_retention_period" { }
variable "maintenance_window" {
  default = "TUE:03:00-TUE:05:00"
}

module "redshift" {
  source = "../terraform/redshift"

  k8s_environment = "${var.k8s_environment}"
  tenant_id = "${var.tenant_id}"
  cluster_name = "${var.cluster_name}"
  solution_abbreviation = "${var.solution_abbreviation}"
  instance_id = "${var.instance_id}"
  database_name = "${var.database_name}"
  master_username = "${var.master_username}"
  master_password = "${var.master_password}"
  cluster_type = "${var.cluster_type}"
  node_type = "${var.node_type}"
  number_of_nodes = "${var.number_of_nodes}"
  iam_roles = "${var.iam_roles}"
  maintenance_window = "${var.maintenance_window}"
  kms_key_name = "${var.kms_key_name}"
  snapshot_retention_period = "${var.snapshot_retention_period}"
}
