module "KEK_Stack" {
  source = "./KekStack"
  es_domain_name = ""
  cloudtrail_s3_bucket = ""
  failure_s3_bucket = ""
}

output "kibana_endpoint" {
  value = "http://${module.KEK_Stack.kibana_endpoint}"
}
