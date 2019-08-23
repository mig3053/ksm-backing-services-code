##
# General config
##

variable "solutionName" {
  description = "Solution Name"
  type        = "string"
}

variable "environment" {
  description = "Environment"
  type        = "string"
}

variable "clusterName" {
  type = "string"
}

variable "tenantId" {
  type = "string"
}

variable "azDbName" {
  type = "string"
}

##
# Azure config
##

variable "rgName" {
  description = "Resource Group Name"
  type        = "string"
}

variable "location" {
  description = "Azure Location Name"
  type        = "string"
}

variable PGsku {
  description = "SKU for PostgreSQL server"
  type        = "map"

  /*
  default = {
    name     = "B_Gen4_2"
    capacity = 2
    tier     = "Basic"
    family   = "Gen4"
  }
*/
}

variable "PGstorageProfile" {
  description = "Storage Profile for the PostgreSQL server"
  type        = "map"

  /*
  default = {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }
*/
}

variable "PGadminName" {
  description = "Admin name for the postgreSQL server"
  type        = "string"

  /*
  default     = "pgadminuser"
*/
}

variable "PGversion" {
  description = "Version of PostgreSQL"
  type        = "string"

  /*
  default     = "9.5"                   # Other options: "9.6", "10.0"
*/
}

variable "PGpassword" {
  description = "Password for PostgreSQL admin"
  type        = "string"
}

variable "PGdbNames" {
  description = "Name of PostgreSQL database"
  type        = "list"

  /*
  default = [
    "PGDBName01",
    "PGDBName02",
    "PGDBName03",
  ]
*/
}

variable "PGcharset" {
  description = "Name of PostgreSQL database"
  type        = "string"

  /*
  default     = "UTF8"
*/
}

variable "PGcollation" {
  description = "Name of PostgreSQL database"
  type        = "string"

  /*
  default     = "English_United States.1252"
*/
}

variable "sourceIPs" {
  description = "a list of source IP starts and ends to add to the Firewall rules"
  type        = "list"

  /*
  default = [
    ["0.0.0.0", "128.128.128.128"],
    ["128.128.128.128", "255.255.255.255"],
  ]
*/
}
