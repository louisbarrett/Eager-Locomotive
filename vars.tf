variable "es_domain_name" {
  description = "Name to assign the Elasticsearch domain"
}

# variable "cloudtrail_s3_bucket" {
#   description = "The name to assign to the Cloudtrail logs bucket"
# default ="${var.es_domain_name}_cloudtrail_logs"
# }

# variable "failure_s3_bucket" {
#   description = "The name to assign to the firehose delivery failure bucket"
#   default ="${var.es_domain_name}_kinesis_failed_logs"
# }

variable "public_ip" {
  description = "Enter the public IP from which you will connect to Kibana"
}
