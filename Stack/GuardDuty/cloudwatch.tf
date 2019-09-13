resource "aws_iam_role" "cloudwatch-role" {
  name               = "cloudwatch-role"
  assume_role_policy = "${data.aws_iam_policy_document.cloudwatch-assumerole.json}"
}

data "aws_iam_policy_document" "cloudwatch-assumerole" {
  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals  {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "cloudwatch-policy" {
  name        = "cloudwatch-policy"
  description = "policy needed to send guardduty findings to es"
  policy      = "${data.aws_iam_policy_document.cloudwatch-policy.json}"
}

data "aws_iam_policy_document" "cloudwatch-policy" {
  statement {
    sid       = "KinesisPutRecordsAccess"
    effect    = "Allow"
    actions   = ["kinesis:PutRecords", "kinesis:PutRecord"]
    resources = ["arn:aws:kinesis:*:*:stream/incoming-guardduty"]
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch-policy" {
  role       = "${aws_iam_role.cloudwatch-role.name}"
  policy_arn = "${aws_iam_policy.cloudwatch-policy.arn}"
}