provider "aws" {
  version = "~> 1.60"
}

resource "aws_sqs_queue" "main_queue" {
  name                              = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.queue_id}${var.fifo_queue ? ".fifo" : ""}"
  delay_seconds                     = "${var.delay_seconds}"
  visibility_timeout_seconds        = "${var.visibility_timeout_seconds}"
  max_message_size                  = "${var.max_message_size}"
  message_retention_seconds         = "${var.message_retention_seconds}"
  receive_wait_time_seconds         = "${var.receive_wait_time_seconds}"
  fifo_queue                        = "${var.fifo_queue}"
  content_based_deduplication       = "${var.content_based_deduplication}"
  kms_master_key_id                 = "${data.aws_kms_alias.main.arn}"
  kms_data_key_reuse_period_seconds = "${var.kms_data_key_reuse_period_seconds}"

  tags {
    Name              = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.queue_id}${var.fifo_queue ? ".fifo" : ""}"
    Solution          = "${var.solution_abbreviation}"
    KubernetesCluster = "${var.cluster_name}"
    Environment       = "${var.k8s_environment}"
    Tenant            = "${var.tenant_id}"
    Namespace         = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}"
  }
}

resource "aws_iam_role" "main_queue_role" {
  name = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.queue_id}-sqs_iam_role"

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

resource "aws_iam_role_policy_attachment" "sqs_role_ses_policy_role_attachment" {
  role       = "${aws_iam_role.main_queue_role.name}"
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/sespolicy"
}

resource "aws_iam_role_policy" "main_queue_role_policy" {
  name = "${var.solution_abbreviation}-${var.k8s_environment}-${var.tenant_id}-${var.queue_id}-sqs_iam_role_policy"
  role = "${aws_iam_role.main_queue_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ListQueues",
        "sqs:GetQueueUrl",
        "sqs:DeleteMessage",
        "sqs:SendMessage",
        "sqs:ReceiveMessage"
      ],
      "Resource": [ "${aws_sqs_queue.main_queue.arn}" ]
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
