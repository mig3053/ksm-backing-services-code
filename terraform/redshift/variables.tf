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