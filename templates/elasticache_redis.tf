variable "k8s_environment" { }
variable "cluster_name" { }
variable "tenant_id" { }
variable "solution_abbreviation" { }
variable "instance_id" {}

variable "number_cache_clusters" {
  description = "Number of cache clusters."
  default = "1"
}

variable "port" {
  description = "Elasticache cluster port to create in mysql."
  default = "6379"
}

variable "node_type" {
  description = "The AWS instance type for the REDIS instance."
  default = "cache.m4.large"
}

variable "engine_version" {
  description = "Redis version. Keep the default of 3.2.6 when AUTH and encryption is needed."
  default = "3.2.6"
}

variable "apply_immediately" {
  description = "Should database modifications be applied immediately, or during the next maintenance window."
  default = "false"
}

variable "parameter_group_name" {
  description = "Name of the parameter group to associate with this cache cluster."
  default = "default.redis3.2"
}

variable "auto_minor_version_upgrade" {
  description = "Specifies whether a minor engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window."
  default = "true"
}

variable "auth_token" {
  description = "The password used to access a password protected server. Can be specified only if transit_encryption_enabled = true"
}

variable "maintenance_window" {
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: sun:05:00-sun:09:00"
  default = "sun:05:00-sun:09:00"
}

variable "automatic_failover_enabled" {
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails. Defaults to false"
  default = "false"
}

module "elasticache_redis" {
  source = "../terraform/elasticache_redis"

  k8s_environment = "${var.k8s_environment}"
  tenant_id = "${var.tenant_id}"
  cluster_name = "${var.cluster_name}"
  solution_abbreviation = "${var.solution_abbreviation}"
  instance_id = "${var.instance_id}"
  node_type = "${var.node_type}"
  number_cache_clusters = "${var.number_cache_clusters}"
  port = "${var.port}"
  node_type = "${var.node_type}"
  engine_version = "${var.engine_version}"
  apply_immediately = "${var.apply_immediately}"
  parameter_group_name = "${var.parameter_group_name}"
  auto_minor_version_upgrade = "${var.auto_minor_version_upgrade}"
  auth_token = "${var.auth_token}"
  maintenance_window = "${var.maintenance_window}"
  automatic_failover_enabled = "${var.automatic_failover_enabled}"
}

output "primary_endpoint_address" {
    value = "${module.elasticache_redis.primary_endpoint_address}"
}

output "configuration_endpoint_address" {
    value = "${module.elasticache_redis.configuration_endpoint_address}"
}

