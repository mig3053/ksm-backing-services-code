output "db_hostname" {
  value = "${aws_route53_record.db_address.fqdn}"
}