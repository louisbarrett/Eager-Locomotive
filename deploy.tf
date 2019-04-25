module "MonitoringStack" {
  source               = "./Stack"
  es_domain_name       = "${var.es_domain_name}"
  cloudtrail_s3_bucket = "${var.cloudtrail_s3_bucket}"
  failure_s3_bucket    = "${var.failure_s3_bucket}"
  public_ip            = "${var.public_ip}"
}

output "kibana_endpoint" {
  value = "http://${module.MonitoringStack.kibana_endpoint}"
}
