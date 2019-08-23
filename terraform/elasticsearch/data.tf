data "aws_caller_identity" "current" {}

data "aws_kms_alias" "main" {
  name = "alias/${var.kms_key_name}"
}

data "aws_kms_key" "main" {
  key_id = "alias/${var.kms_key_name}"
}

data "aws_region" "main" {}

data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = ["nodes.${var.cluster_name}*"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_security_group.main.vpc_id}"

  tags {
    Name = "${var.cluster_name}-svc-subnet-*"
  }
}
