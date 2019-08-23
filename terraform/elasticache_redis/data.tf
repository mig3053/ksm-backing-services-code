data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = ["nodes.${var.cluster_name}*"]
  }
}

data "aws_region" "main" {
//  current = true
}

data "aws_subnet_ids" "private" {
  vpc_id = "${data.aws_security_group.main.vpc_id}"
  tags {
    Name = "${var.cluster_name}-svc-subnet-*"
  }
}
