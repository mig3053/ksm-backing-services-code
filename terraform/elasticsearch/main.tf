provider "aws" {
  version = "~> 1.60"
}

resource "aws_elasticsearch_domain" "main_es" {
  domain_name           = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.elasticsearch_name}"
  elasticsearch_version = "${var.elasticsearch_version}"

  access_policies = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": {
        "AWS": [
          "*"
        ]
      },
      "Action": [
        "es:*"
      ],
      "Resource": "arn:aws:es:${data.aws_region.main.name}:${data.aws_caller_identity.current.account_id}:domain/${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.elasticsearch_name}/*"
    }
  ]
}
EOF

  ebs_options {
    ebs_enabled = "true"
    volume_type = "gp2"
    volume_size = "${var.volume_size}"
  }

  encrypt_at_rest {
    enabled    = "true"
    kms_key_id = "${data.aws_kms_alias.main.arn}"
  }

  cluster_config {
    instance_type            = "${var.instance_type}"
    instance_count           = "${var.instance_count}"
    dedicated_master_enabled = "${var.dedicated_master_enabled}"
    dedicated_master_type    = "${var.dedicated_master_type}"
    dedicated_master_count   = "${var.dedicated_master_count}"
    zone_awareness_enabled   = "${var.zone_awareness_enabled}"
  }

  vpc_options {
    security_group_ids = ["${data.aws_security_group.main.id}"]
    subnet_ids         = ["${element(data.aws_subnet_ids.private.ids, 0)}", "${var.zone_awareness_enabled ? element(data.aws_subnet_ids.private.ids, 1) : ""}"]
  }

  snapshot_options {
    automated_snapshot_start_hour = "${var.automated_snapshot_start_hour}"
  }

  tags {
    Name              = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.elasticsearch_name}"
    Solution          = "${var.solution_abbreviation}"
    KubernetesCluster = "${var.cluster_name}"
    Environment       = "${var.k8s_environment}"
    Tenant            = "${var.tenant_id}"
    Namespace         = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
  }
}

resource "aws_iam_role" "main_es_role" {
  name = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.elasticsearch_name}-es_iam_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/nodes.${var.cluster_name}"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "es_role_ses_policy_role_attachment" {
  role       = "${aws_iam_role.main_es_role.name}"
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/sespolicy"
}

resource "aws_iam_role_policy" "main_es_role_policy" {
  name = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.elasticsearch_name}-es_iam_role_policy"
  role = "${aws_iam_role.main_es_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "es:*"
      ],
      "Resource": [ "${aws_elasticsearch_domain.main_es.arn}" ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": ["${data.aws_kms_alias.main.arn}","${data.aws_kms_key.main.arn}"]
    }
  ]
}
EOF
}
