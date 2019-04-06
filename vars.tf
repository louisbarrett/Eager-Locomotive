variable "cloudtrail_s3_bucket" {
  description = "The name to assign to the Cloudtrail logs bucket"
}

variable "failure_s3_bucket" {
  description = "The name to assign to the firehose delivery failure bucket"
}

variable "es_domain_name" {
  description = "Name to assign the Elasticsearch domain"
}

variable "public_ip" {
  description = "Enter the public IP from which you will connect to Kibana"
}
