output "es_arn" {
  value = "${aws_elasticsearch_domain.main_es.arn}"
}

output "es_domain_id" {
  value = "${aws_elasticsearch_domain.main_es.domain_id}"
}

output "es_endpoint" {
  value = "${aws_elasticsearch_domain.main_es.endpoint}"
}

output "es_kibana_endpoint" {
  value = "${aws_elasticsearch_domain.main_es.kibana_endpoint}"
}
