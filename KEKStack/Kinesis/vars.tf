variable "delivery_failure_bucket_name" {
  description = "Name of the S3 bucket where kinesis failure logs will be sent"
  default     = "kekstack_failed_logs"
}

variable "stream_shard_count" {
  description = "Number of shards to stream"
  default     = 1
}

variable "log_source" {
  description = "Name of the kinesis stream set"
}

variable "elasticsearch_arn" {
  description = "arn of target elastic search domain"
  default     = ""
}

variable "index_rotation_interval" {
  description = "How often will we rotate indexes"
  default     = "NoRotation"
}

variable "document_type" {
  default = "logevent"
}
