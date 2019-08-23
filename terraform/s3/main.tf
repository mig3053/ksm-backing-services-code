provider "aws" {
  version = "~> 1.60"
}

resource "aws_s3_bucket" "encryptedbucket" {
  bucket = "${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags {
    Name = "${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}"
    Solution = "${var.solution}"
    KubernetesCluster = "${var.cluster_name}"
    Environment = "${var.k8s_environment}"
    Tenant = "${var.tenant_id}"
    Namespace = "${var.solution}-${var.k8s_environment}-${var.tenant_id}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${var.kms_key_name}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

data "aws_iam_policy_document" "encrypted_bucket_policy" {
  statement {
    sid = "DenyUnEncryptedObjectUploads"
    effect = "Deny"
    actions = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}/*"]
    condition {
      test = "StringNotEquals"
      values = ["aws:kms"]
      variable = "s3:x-amz-server-side-encryption"
    }
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
  }

  statement {
    sid = "DenyUnEncryptedInflightOperations"
    effect = "Deny"
    actions = ["s3:*"]
    resources = ["arn:aws:s3:::${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}/*"]
    condition {
      test = "Bool"
      values = [false]
      variable = "aws:SecureTransport"
    }
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "encrypted_bucket" {
  bucket = "${aws_s3_bucket.encryptedbucket.id}"
  policy = "${data.aws_iam_policy_document.encrypted_bucket_policy.json}"
}

#Create Instance Role for S3 access.

resource "aws_iam_role" "s3_iam_role" {
  name = "${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}_s3_iam_role"
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

resource "aws_iam_role_policy_attachment" "s3_role_ses_policy_role_attachment" {
  role       = "${aws_iam_role.s3_iam_role.name}"
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/sespolicy"
}

resource "aws_iam_instance_profile" "s3_instance_profile" {
    name = "${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}_s3_instance_profile"
    role = "${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}_s3_iam_role"
}

resource "aws_iam_role_policy" "s3_iam_role_policy" {
  name = "${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}_s3_iam_role_policy"
  role = "${aws_iam_role.s3_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${var.solution}-${var.tenant_id}-${var.k8s_environment}-${var.bucket_name}/*"]
    },
    {
    "Effect": "Allow",
    "Action": [
      "kms:Encrypt",
      "kms:Decrypt"
    ],
    "Resource": ["${var.kms_key_name}"]
  }
  ]
}
EOF
}
