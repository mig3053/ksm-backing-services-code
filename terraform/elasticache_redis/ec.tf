provider "aws" {
  version = "~> 1.60"
}

locals {
    default_tags {
        Name              = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
        Solution          = "${var.solution_abbreviation}"
        KubernetesCluster = "${var.cluster_name}"
        Environment       = "${var.k8s_environment}"
        Tenant            = "${var.tenant_id}"
        Namespace         = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
    }
}

resource "aws_elasticache_subnet_group" "subnet_group" {
  name                    = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.instance_id}"
  subnet_ids              = ["${data.aws_subnet_ids.private.ids}"]
}

resource "aws_security_group" "sg" {
  name                    = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.instance_id}"
  description             = "ElastiCache security group for ${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
  vpc_id                  = "${data.aws_security_group.main.vpc_id}"
  ingress {
    from_port             = "${var.port}"
    to_port               = "${var.port}"
    protocol              = "tcp"
    security_groups       = ["${data.aws_security_group.main.id}"]
  }
  # outbound internet access
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }

  tags                    = "${local.default_tags}"
}

resource "aws_elasticache_replication_group" "redis_replication_group" {
  # Replication group id is max. 20 characters, so removed solution_abbrev to keep it unique
  replication_group_id          = "${var.k8s_environment}-${var.tenant_id}-${var.instance_id}"
  replication_group_description = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.instance_id}"  
  number_cache_clusters         = "${var.number_cache_clusters}"
  node_type                     = "${var.node_type}"
  port                          = "${var.port}"  
  automatic_failover_enabled    = "${var.automatic_failover_enabled}"
  auto_minor_version_upgrade    = "${var.auto_minor_version_upgrade}"
  parameter_group_name          = "${var.parameter_group_name}"  
  engine                        = "redis"
  engine_version                = "${var.engine_version}"
  at_rest_encryption_enabled    = "true"
  transit_encryption_enabled    = "true"
  auth_token                    = "${var.auth_token}"
  subnet_group_name             = "${aws_elasticache_subnet_group.subnet_group.name}"
  maintenance_window            = "${var.maintenance_window}"
  security_group_ids            = ["${aws_security_group.sg.id}"]
  apply_immediately             = "${var.apply_immediately}"
  tags                          = "${local.default_tags}"
}
