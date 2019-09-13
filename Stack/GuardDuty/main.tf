resource "aws_guardduty_detector" "primary" {
  enable = true
}


#Kinesis stream for GuardDuty findings
module "GuardDutyKinesisToElasticsearch" {
  source                       = "../Kinesis/"
  log_source                   = "guardduty"
  elasticsearch_arn            = "${var.elasticsearch_arn}"
  delivery_failure_bucket_name = "${var.delivery_failure_s3_bucket}"
  stream_shard_count           = 1
}

resource "aws_cloudwatch_event_rule" "guardduty-newfinding" {
  name        = "guardduty-newfinding"
  description = "Sends new GuardDutyFindings to Kinesis/ES and SNS"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ]
}
PATTERN
}

#Cloudwatch event target linked to guardduty kinesis stream
resource "aws_cloudwatch_event_target" "new-guardduty-kinesis" {
  target_id = "guardduty"
  rule      = "${aws_cloudwatch_event_rule.guardduty-newfinding.name}"
  arn       = "${module.GuardDutyKinesisToElasticsearch.stream_arn}"
  role_arn  = "${aws_iam_role.cloudwatch-role.arn}"
}