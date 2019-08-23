variable "allocated_storage" { }
variable "backup_retention_period" { }
variable "engine" { }
variable "engine_version" { }
variable "instance_class" { }
variable "k8s_environment" { }
variable "cluster_name" { }
variable "db_name" { }
variable "db_master_username" { }
variable "db_master_password_plaintext" { }
variable "multi_az" { }
variable "solution_abbreviation" { }
variable "storage_type" { }
variable "kms_key_name" { }
variable "tenant_id" { }
variable "license_model" {
  default = "license-included"
}
variable "instance_id" {
  default = "main"
}
variable "db_default_ports" {
  type        = "map"
  description = "Map of default ports for supported DB engines"

  default = {
    "aurora"        = 3306
    "mariadb"       = 3306
    "mysql"         = 3306
    "oracle-ee"     = 1521
    "oracle-se2"    = 1521
    "oracle-se1"    = 1521
    "oracle-se"     = 1521
    "postgres"      = 5432
    "sqlserver-ee"  = 1433
    "sqlserver-se"  = 1433
    "sqlserver-ex"  = 1433
    "sqlserver-web" = 1433
  }
}

variable "parameter_group_family_suffix" {
  type        = "map"
  description = "Map of DB engine versions and the parameter group family"

  default = {
    "10.1.23"        = "10.1"
    "10.1.19"       = "10.1"
    "10.1.14"         = "10.1"
    "10.0.31"     = "10.0"
    "10.0.28"    = "10.0"
    "10.0.24"    = "10.0"
    "10.0.17"     = "10.0"
    "13.00.4422.0.v1"      = "-13.0"
    "13.00.2164.0.v1"  = "-13.0"
    "12.00.5546.0.v1"  = "-12.0"
    "12.00.5000.0.v1"  = "-12.0"
    "12.00.4422.0.v1" = "-12.0"
    "11.00.6594.0.v1" = "-11.0"
    "11.00.6020.0.v1" = "-11.0"
    "11.00.5058.0.v1" = "-11.0"
    "11.00.2100.60.v1" = "-11.0"
    "10.50.6529.0.v1" = "-10.5"
    "10.50.6000.34.v1" = "-10.5"
    "10.50.2789.0.v1" = "-10.5"
    "5.7" = "5.7"
    "5.7.19" = "5.7"
    "5.7.18" = "5.7"
    "5.7.17" = "5.7"
    "5.7.16" = "5.7"
    "5.7.11" = "5.7"
    "5.6" = "5.6"
    "5.6.35" = "5.6"
    "5.6.34" = "5.6"
    "5.6.29" = "5.6"
    "5.6.27" = "5.6"
    "5.5.54" = "5.5"
    "5.5.53" = "5.5"
    "5.5.46" = "5.5"
    "12.1.0.2.v8" = "-12.1"
    "12.1.0.2.v7" = "-12.1"
    "12.1.0.2.v6" = "-12.1"
    "12.1.0.2.v5" = "-12.1"
    "12.1.0.2.v4" = "-12.1"
    "12.1.0.2.v3" = "-12.1"
    "12.1.0.2.v2" = "-12.1"
    "12.1.0.2.v1" = "-12.1"
    "11.2.0.4.v12" = "-11.2"
    "11.2.0.4.v11" = "-11.2"
    "11.2.0.4.v10" = "-11.2"
    "11.2.0.4.v9" = "-11.2"
    "11.2.0.4.v8" = "-11.2"
    "11.2.0.4.v7" = "-11.2"
    "11.2.0.4.v6" = "-11.2"
    "11.2.0.4.v5" = "-11.2"
    "11.2.0.4.v4" = "-11.2"
    "11.2.0.4.v3" = "-11.2"
    "11.2.0.4.v1" = "-11.2"
    "9.6" = "9.6"
    "9.6.1" = "9.6"
    "9.6.2" = "9.6"
    "9.6.3" = "9.6"
    "9.6.5" = "9.6"
    "9.5" = "9.5"
    "9.5.6" = "9.5"
    "9.5.4" = "9.5"
    "9.5.2" = "9.5"
    "9.4" = "9.4"
    "9.4.11" = "9.4"
    "9.4.9" = "9.4"
    "9.4.7" = "9.4"
    "9.3" = "9.3"
    "9.3.16" = "9.3"
    "9.3.14" = "9.3"
    "9.3.12" = "9.3"
  }
}