variable "solutionName" {}
variable "environment" {}
variable "clusterName" {}
variable "tenantId" {}
variable "rgName" {}
variable "location" {}
variable "PGsku" { type = "map" }
variable "PGstorageProfile" { type = "map" }
variable "PGadminName" {}
variable "PGversion" {}
variable "PGpassword" {}
variable "PGdbNames" { type = "list" }
variable "PGcharset" {}
variable "PGcollation" {}
variable "sourceIPs" { type = "list" }
variable "azDbName" {}

module "postgres" {
  source                       = "../terraform/azr_db_for_postgres"
  solutionName = "${var.solutionName}"
  environment = "${var.environment}"
  clusterName = "${var.clusterName}"
  tenantId = "${var.tenantId}"
  rgName = "${var.rgName}"
  location = "${var.location}"
  PGsku = "${var.PGsku}"
  PGstorageProfile = "${var.PGstorageProfile}"
  PGadminName = "${var.PGadminName}"
  PGversion = "${var.PGversion}"
  PGpassword = "${var.PGpassword}"
  PGdbNames = "${var.PGdbNames}"
  PGcharset = "${var.PGcharset}"
  PGcollation = "${var.PGcollation}"
  sourceIPs = "${var.sourceIPs}"
  azDbName = "${var.azDbName}"
}

output "db_hostname" {
  value = "${module.postgres.PostgreSQL_fqdn}"
}
