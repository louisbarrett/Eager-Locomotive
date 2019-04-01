module "KEK_Stack" {
  source = "./KekStack"
  es_domain_name = "siemstress"
  cloudtrail_s3_bucket = "siemstress-cloudtrail-logs"
  failure_s3_bucket = "siemstress-failed-logs"
}
output "kibana_endpoint" {
  value = "http://${module.KEK_Stack.kibana_endpoint}"
}
