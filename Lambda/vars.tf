variable "cloudtrail_s3_bucket" {
  default = "kekstack-cloudtrail-logs"
}

variable "stream_name" {
  default = "incoming-cloudtrail"
}

variable "count" {
  default = 1
}
