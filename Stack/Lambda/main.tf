resource "aws_lambda_function" "cloudtrail-kin" {
  function_name = "cloudtrail-kin"
  description   = "Delivers centralized cloudtrail logs into elasticsearch"
  filename      = "./Stack/Deployment/cloudtrail-kin.zip"
  handler       = "cloudtrail-kin"
  runtime       = "go1.x"
  role          = "${aws_iam_role.lambda-role.arn}"
  timeout       = 900
  memory_size   = 128

  environment = {
    variables {
      KINESIS_STREAM = "${var.stream_name}"
      SHARD_COUNT    = 3
    }
  }
}

resource "aws_iam_role" "lambda-role" {
  name               = "CloudTrailToKinesis"
  assume_role_policy = "${data.aws_iam_policy_document.CloudTrailAssumeRole.json}"
}

data "aws_iam_policy_document" "CloudTrailAssumeRole" {
  statement {
    sid    = "LambdaAssumeRole"
    effect = "Allow"

    principals = {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy_attachment" "LambdaAccess" {
  name       = "LambaAccessS3Kinesis"
  roles      = ["${aws_iam_role.lambda-role.name}"]
  policy_arn = "${aws_iam_policy.CloudTrailLambdaAccess.arn}"
}

resource "aws_iam_policy" "CloudTrailLambdaAccess" {
  name   = "CloudTrailLambdaAccess"
  policy = "${data.aws_iam_policy_document.CloudTrailS3ToKin.json}"
}

data "aws_iam_policy_document" "CloudTrailS3ToKin" {
  statement {
    sid       = "S3ReadCloudTrailLogs"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.cloudtrail_s3_bucket}/AWSLogs/*"]
  }

  statement {
    sid       = "KinesisPutCloudTrailLogs"
    effect    = "Allow"
    actions   = ["kinesis:Put*"]
    resources = ["*"]
  }

  statement {
    sid       = "LogsAccess"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

#allows s3 operations from the ops account to trigger cloudtrail delivery to es
resource "aws_lambda_permission" "s3-invoke-cloudtrail-kin" {
  statement_id  = "invoke-cloudtrail-kin"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cloudtrail-kin.function_name}"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.cloudtrail_s3_bucket}"
}
