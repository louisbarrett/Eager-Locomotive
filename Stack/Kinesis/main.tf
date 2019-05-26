resource aws_kinesis_stream "incoming-logs" {
  name             = "incoming-${var.log_source}"
  shard_count      = "${var.stream_shard_count}"
  retention_period = 48
}

resource aws_kinesis_firehose_delivery_stream "outgoing-firehose-es" {
  name        = "${var.log_source}-logs-es"
  destination = "elasticsearch"

  kinesis_source_configuration {
    kinesis_stream_arn = "${aws_kinesis_stream.incoming-logs.arn}"
    role_arn           = "${aws_iam_role.firehose_role.arn}"
  }

  s3_configuration {
    role_arn           = "${aws_iam_role.firehose_role.arn}"
    bucket_arn         = "${aws_s3_bucket.delivery_failure_bucket.arn}"
    buffer_size        = 2
    buffer_interval    = 60
    compression_format = "GZIP"
    prefix             = "${var.log_source}/"
  }

  elasticsearch_configuration {
    domain_arn            = "${var.elasticsearch_arn}"
    role_arn              = "${aws_iam_role.firehose_role.arn}"
    index_name            = "${var.log_source}"
    type_name             = "${var.document_type}"
    index_rotation_period = "${var.index_rotation_interval}"
    buffering_interval    = 60
    buffering_size        = 1
  }
}

resource "aws_s3_bucket" "delivery_failure_bucket" {
  bucket        = "${var.delivery_failure_bucket_name}"
  force_destroy = true
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose-es"
  assume_role_policy = "${data.aws_iam_policy_document.kinesis-assumerole.json}"
}

data "aws_iam_policy_document" "kinesis-assumerole" {
  statement {
    sid     = "AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals  {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "kinesis-policy" {
  name        = "kinesis-policy"
  description = "Policy for kiensis to write into es"
  policy      = "${data.aws_iam_policy_document.kinesis-policy-document.json}"
}

data aws_iam_policy_document "kinesis-policy-document" {
  statement {
    sid    = "kinesisLambda"
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]

    resources = [
      "arn:aws:lambda:us-west-2:*:function:%FIREHOSE_DEFAULT_FUNCTION%:%FIREHOSE_DEFAULT_VERSION%",
    ]
  }

  statement {
    sid    = "AllowKinesisESPut"
    effect = "Allow"

    actions = [
      "es:DescribeElasticsearchDomain",
      "es:DescribeElasticsearchDomains",
      "es:DescribeElasticsearchDomainConfig",
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = ["${var.elasticsearch_arn}/*", "${var.elasticsearch_arn}"]
  }

  statement {
    sid    = "AllowKinesisESGet"
    effect = "Allow"

    actions = ["es:ESHttpGet"]

    resources = [
      "${var.elasticsearch_arn}*",
    ]
  }

  statement {
    sid    = "AllowKinesisStreamRead"
    effect = "Allow"

    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
    ]

    # Caller ARN

    resources = ["*"]
  }

  statement {
    sid    = "AllowKinesisS3Write"
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]

    resources = ["${aws_s3_bucket.delivery_failure_bucket.arn}", "${aws_s3_bucket.delivery_failure_bucket.arn}/*"]
  }

  statement {
    sid     = "WriteLogs"
    effect  = "Allow"
    actions = ["logs:PutLogEvents"]

    #consider using the account ID here directly
    resources = ["arn:aws:logs:us-west-2:*:log-group:/aws/kinesisfirehose/*:log-stream:*"]
  }
}

resource "aws_iam_role_policy_attachment" "kinesis-policy" {
  role       = "${aws_iam_role.firehose_role.name}"
  policy_arn = "${aws_iam_policy.kinesis-policy.arn}"
}
