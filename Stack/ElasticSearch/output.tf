output "arn" {
  value = "${aws_elasticsearch_domain.es.arn}"
}

output "kibana_endpoint" {
  value = "${aws_elasticsearch_domain.es.kibana_endpoint}"
}
