variable "automated_snapshot_start_hour" {}
variable "cluster_name" {}
variable "dedicated_master_count" {}
variable "dedicated_master_enabled" {}
variable "dedicated_master_type" {}
variable "elasticsearch_name" {}
variable "elasticsearch_version" {}
variable "instance_count" {}
variable "instance_type" {}
variable "k8s_environment" {}
variable "kms_key_name" {}
variable "solution" {}
variable "tenant_id" {}
variable "volume_size" {}
variable "zone_awareness_enabled" {}

module "elasticsearch" {
  source                        = "../terraform/elasticsearch"
  automated_snapshot_start_hour = "${var.automated_snapshot_start_hour}"
  cluster_name                  = "${var.cluster_name}"
  dedicated_master_count        = "${var.dedicated_master_count}"
  dedicated_master_enabled      = "${var.dedicated_master_enabled}"
  dedicated_master_type         = "${var.dedicated_master_type}"
  elasticsearch_name            = "${var.elasticsearch_name}"
  elasticsearch_version         = "${var.elasticsearch_version}"
  instance_count                = "${var.instance_count}"
  instance_type                 = "${var.instance_type}"
  k8s_environment               = "${var.k8s_environment}"
  kms_key_name                  = "${var.kms_key_name}"
  solution_abbreviation         = "${var.solution}"
  tenant_id                     = "${var.tenant_id}"
  volume_size                   = "${var.volume_size}"
  zone_awareness_enabled        = "${var.zone_awareness_enabled}"
}

output "es_arn" {
  value = "${module.elasticsearch.es_arn}"
}

output "es_domain_id" {
  value = "${module.elasticsearch.es_domain_id}"
}

output "es_endpoint" {
  value = "${module.elasticsearch.es_endpoint}"
}

output "es_kibana_endpoint" {
  value = "${module.elasticsearch.es_kibana_endpoint}"
}
