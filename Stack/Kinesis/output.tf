output "firehose_arn" {
  value = "${aws_iam_role.firehose_role.arn}"
}
output "failure_bucket_arn" {
  value = "${aws_s3_bucket.delivery_failure_bucket.arn}"
}

output "stream_arn" {
  value = "${aws_kinesis_stream.incoming-logs.arn}"
}
