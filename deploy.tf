module "MonitoringStack" {
  source               = "./Stack"
  es_domain_name       = var.es_domain_name
  cloudtrail_s3_bucket = "${var.es_domain_name}-cloudtrail-logs"
  failure_s3_bucket    = "${var.es_domain_name}-kinesis-failed-logs"
  public_ip            = var.public_ip
}

output "kibana_endpoint" {
  value = "http://${module.MonitoringStack.kibana_endpoint}"
}

