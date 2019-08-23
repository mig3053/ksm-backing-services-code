##
# General config
##

variable "solution" {
  description = "Solution Name"
  type        = "string"
}

variable "environment" {
  description = "Environment"
  type        = "string"
}

variable "azDbName" {
  type = "string"
}

##
# Azure config
##

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = "string"
}

/*
variable "location" {
  description = "Azure Location Name"
  type        = "string"
}
*/
variable "tags" {
  description = "Tags"
  type        = "map"
  default     = {}
}

##
# PostgreSQL config
##

variable PGsku {
  description = "SKU for PostgreSQL server"
  type        = "map"
}

variable "PGstorageProfile" {
  description = "Storage Profile for the PostgreSQL server"
  type        = "map"
}

variable "PGadminName" {
  description = "Admin name for the postgreSQL server"
  type        = "string"
}

variable "PGversion" {
  description = "Version of PostgreSQL"
  type        = "string"
}

variable "PGpassword" {
  description = "Password for PostgreSQL admin"
  type        = "string"
}

variable "PGdbNames" {
  description = "Name of PostgreSQL database"
  type        = "list"
}

variable "PGcharset" {
  description = "Name of PostgreSQL database"
  type        = "string"
}

variable "PGcollation" {
  description = "Name of PostgreSQL database"
  type        = "string"
}

variable "sourceIPs" {
  description = "a list of source IP starts and ends to add to the Firewall rules"
  type        = "list"
}
