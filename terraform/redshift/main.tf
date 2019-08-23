provider "aws" {
  version = "~> 1.60"
}

locals {
    default_tags {
        Name = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
        Solution = "${var.solution_abbreviation}"
        KubernetesCluster = "${var.cluster_name}"
        Environment = "${var.k8s_environment}"
        Tenant = "${var.tenant_id}"
        Namespace = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
    }
}

resource "aws_redshift_subnet_group" "subnet_group" {
  name       = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.instance_id}"
  subnet_ids = ["${data.aws_subnet_ids.private.ids}"]

  tags = "${local.default_tags}"
}

resource "aws_security_group" "sec_group" {
  name    = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.instance_id}"
  vpc_id = "${data.aws_security_group.main.vpc_id}"
  ingress {
    from_port       = "5439"
    to_port         = "5439"
    protocol        = "tcp"
    security_groups = ["${data.aws_security_group.main.id}"]
  }
  tags = "${local.default_tags}"
}

resource "aws_redshift_parameter_group" "params" {
  name   = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.instance_id}"
  family = "redshift-1.0"

  parameter {
    name  = "require_ssl"
    value = "true"
  }
}

resource "aws_redshift_cluster" "cluster" {
    cluster_identifier = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.instance_id}"
    database_name = "${var.database_name}"
    master_username = "${var.master_username}"
    master_password = "${var.master_password}"
    cluster_type = "${var.cluster_type}"
    node_type = "${var.node_type}"
    number_of_nodes = "${var.number_of_nodes}"
    vpc_security_group_ids = ["${aws_security_group.sec_group.id}"]
    cluster_subnet_group_name = "${aws_redshift_subnet_group.subnet_group.name}"
    automated_snapshot_retention_period = "${var.snapshot_retention_period}"
    encrypted = "true"
    kms_key_id = "${data.aws_kms_alias.main.arn}"
    enhanced_vpc_routing = "true"
    publicly_accessible = "false"
    tags = "${local.default_tags}"
    preferred_maintenance_window = "${var.maintenance_window}"
    cluster_parameter_group_name = "${aws_redshift_parameter_group.params.name}"
}
