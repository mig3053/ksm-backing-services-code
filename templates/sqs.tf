variable "cluster_name" {}
variable "content_based_deduplication" {}
variable "delay_seconds" {}
variable "fifo_queue" {}
variable "k8s_environment" {}
variable "kms_data_key_reuse_period_seconds" {}
variable "kms_key_name" {}
variable "max_message_size" {}
variable "message_retention_seconds" {}
variable "queue_id" {}
variable "receive_wait_time_seconds" {}
variable "solution" {}
variable "tenant_id" {}
variable "visibility_timeout_seconds" {}

module "sqs" {
  source                            = "../terraform/sqs"
  cluster_name                      = "${var.cluster_name}"
  content_based_deduplication       = "${var.content_based_deduplication}"
  delay_seconds                     = "${var.delay_seconds}"
  fifo_queue                        = "${var.fifo_queue}"
  k8s_environment                   = "${var.k8s_environment}"
  kms_data_key_reuse_period_seconds = "${var.kms_data_key_reuse_period_seconds}"
  kms_key_name                      = "${var.kms_key_name}"
  max_message_size                  = "${var.max_message_size}"
  message_retention_seconds         = "${var.message_retention_seconds}"
  queue_id                          = "${var.queue_id}"
  receive_wait_time_seconds         = "${var.receive_wait_time_seconds}"
  solution_abbreviation             = "${var.solution}"
  tenant_id                         = "${var.tenant_id}"
  visibility_timeout_seconds        = "${var.visibility_timeout_seconds}"
}

output "sqs_arn" {
  value = "${module.sqs.sqs_arn}"
}
