##
# General config
##

variable "solution" {
  description = "Solution Name"
  type = "string"
}

variable "environment" {
  description = "Environment"
  type = "string"
}

##
# Azure config
##

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = "string"
}

variable "location" {
  description = "Azure Location Name"
  type        = "string"
}

variable "tags" {
  description = "Tags"
  type        = "map"
  default     = {}
}
