variable "cloudtrail_s3_bucket" {}

variable "failure_s3_bucket" {}

variable "es_domain_name" {
  description = "Name to assign the Elasticsearch domain"
}

variable "public_ip" {
  description = "The public IP which will be allowed to reach the ES instance"
}
