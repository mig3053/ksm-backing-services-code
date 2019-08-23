provider "aws" {
  version = "~> 1.60"
}

locals {
  license_required_engines = ["oracle-ee", "oracle-se2", "oracle-se1", "oracle-se", "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"]
  blank_name_engines = ["sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web"]
}

resource "aws_db_subnet_group" "main" {
  name    = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}"
  subnet_ids = ["${data.aws_subnet_ids.private.ids}"]
}

resource "aws_db_instance" "main" {
  allocated_storage         = "${var.allocated_storage}"
  backup_retention_period   = "${var.backup_retention_period}"
  db_subnet_group_name      = "${aws_db_subnet_group.main.id}" 
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  final_snapshot_identifier = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}-final-snapshot"
  identifier                = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}"
  instance_class            = "${var.instance_class}"
  kms_key_id                = "${data.aws_kms_alias.main.arn}"
  multi_az                  = "${var.multi_az}"
  name                      = "${contains(local.blank_name_engines, var.engine) ? "" : var.db_name}"
  password                  = "${var.db_master_password_plaintext}"
  parameter_group_name      = "${aws_db_parameter_group.main.id}"
  storage_encrypted         = true
  storage_type              = "${var.storage_type}"
  username                  = "${var.db_master_username}"
  vpc_security_group_ids    = ["${aws_security_group.db.id}"]
  license_model             = "${contains(local.license_required_engines, var.engine) ? var.license_model : ""}"

  tags {
    Name = "${var.solution_abbreviation}-${var.engine}-${var.k8s_environment}"
    Solution = "${var.solution_abbreviation}"
    KubernetesCluster = "${var.cluster_name}"
    Environment = "${var.k8s_environment}"
    Tenant = "${var.tenant_id}"
    Namespace = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
  }
  count = "${var.engine != "mysql" ? 1 : 0}"
}

resource "aws_db_instance" "main_mysql" {
  allocated_storage         = "${var.allocated_storage}"
  backup_retention_period   = "${var.backup_retention_period}"
  db_subnet_group_name      = "${aws_db_subnet_group.main.id}"
  engine                    = "${var.engine}"
  engine_version            = "${var.engine_version}"
  final_snapshot_identifier = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}-final-snapshot"
  identifier                = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}"
  instance_class            = "${var.instance_class}"
  kms_key_id                = "${data.aws_kms_alias.main.arn}"
  multi_az                  = "${var.multi_az}"
  name                      = "${var.db_name}"
  password                  = "${var.db_master_password_plaintext}"
  parameter_group_name      = "${aws_db_parameter_group.main.id}"
  option_group_name         = "${aws_db_option_group.main.id}" 
  storage_encrypted         = true
  storage_type              = "${var.storage_type}"
  username                  = "${var.db_master_username}"
  vpc_security_group_ids    = ["${aws_security_group.db.id}"]

  tags {
    Name = "${var.solution_abbreviation}-${var.engine}-${var.k8s_environment}"
    Solution = "${var.solution_abbreviation}"
    KubernetesCluster = "${var.cluster_name}"
    Environment = "${var.k8s_environment}"
    Tenant = "${var.tenant_id}"
    Namespace = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
  }
  count = "${var.engine == "mysql" ? 1 : 0}"
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}"
  family = "${var.engine}${var.parameter_group_family_suffix[var.engine_version]}"
  
    tags {
    Name = "${var.solution_abbreviation}-${var.engine}-${var.k8s_environment}"
    Solution = "${var.solution_abbreviation}"
    KubernetesCluster = "${var.cluster_name}"
    Environment = "${var.k8s_environment}"    
    Tenant = "${var.tenant_id}"
    Namespace = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
  }
}

resource "aws_db_option_group" "main" {
  name   = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}"
  engine_name = "${var.engine}"
  major_engine_version = "${var.parameter_group_family_suffix[var.engine_version]}"
  
    tags {
    Name = "${var.solution_abbreviation}-${var.engine}-${var.k8s_environment}"
    Solution = "${var.solution_abbreviation}"
    KubernetesCluster = "${var.cluster_name}"
    Environment = "${var.k8s_environment}"    
    Tenant = "${var.tenant_id}"
    Namespace = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
  }
  count = "${var.engine == "mysql" ? 1 : 0}"
}

resource "aws_security_group" "db" {
  name    = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}.${var.cluster_name}"
  vpc_id = "${data.aws_security_group.main.vpc_id}"
  ingress {
    from_port       = "${var.db_default_ports[var.engine]}"
    to_port         = "${var.db_default_ports[var.engine]}"
    protocol        = "tcp"
    security_groups = ["${data.aws_security_group.main.id}"]
  }
  tags {
    Name = "${var.solution_abbreviation}-${var.engine}-${var.k8s_environment}"
    Solution = "${var.solution_abbreviation}"
    KubernetesCluster = "${var.cluster_name}"
    Environment = "${var.k8s_environment}"
    Tenant = "${var.tenant_id}"
    Namespace = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
  }
}

resource "aws_route53_record" "db_address" {
  zone_id = "${data.aws_route53_zone.main.id}"
  name    = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_db_instance.main.address}"]
  count = "${var.engine != "mysql" ? 1 : 0}"
}

resource "aws_route53_record" "db_address_mysql" {
  zone_id = "${data.aws_route53_zone.main.id}"
  name    = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.engine}-${var.instance_id}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_db_instance.main_mysql.address}"]
  count = "${var.engine == "mysql" ? 1 : 0}"
}