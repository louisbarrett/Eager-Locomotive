variable "cloudtrail_s3_bucket" {
  default = "kekstack-cloudtrail-logs"
}

variable "count" {
  description = "Enable Cloudtrail Logging?"
  default     = 1
}
