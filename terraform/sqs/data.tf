data "aws_caller_identity" "current" {}

data "aws_kms_alias" "main" {
  name = "alias/${var.kms_key_name}"
}

data "aws_kms_key" "main" {
  key_id = "alias/${var.kms_key_name}"
}

data "aws_region" "main" {
  current = true
}
