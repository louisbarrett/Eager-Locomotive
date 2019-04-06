output "firehose_arn" {
  value = "${aws_iam_role.firehose_role.arn}"
}
