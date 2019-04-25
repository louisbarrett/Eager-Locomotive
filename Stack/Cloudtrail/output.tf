output "CloudTrail_S3_Bucket" {
  description = "Bucket where CloudTrail logs are being sent"
  value       = "${aws_s3_bucket.CloudTrail.id}"
}
