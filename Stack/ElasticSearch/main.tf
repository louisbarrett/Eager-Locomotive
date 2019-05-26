resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.ES_Domain}"
  elasticsearch_version = "6.5"

  cluster_config {
    instance_type  = "${var.Instance_Type}"
    instance_count = "${var.ES_Domain_Size}"
  }

  access_policies = "${data.aws_iam_policy_document.es-domain-policy.json}"

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = "${var.Node_Size}"
  }

  encrypt_at_rest {
    enabled = false
  }
}

# Load current execution context
data "aws_caller_identity" "Current" {}

data "aws_iam_policy_document" "es-domain-policy" {
  statement {
    sid     = "AccessElasticSearch"
    effect  = "Allow"
    actions = ["es:*"]

    principals  {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:sourceIp"
      values   = ["${var.public_ip}/32"]
    }
  }
}

# data section for cognito
data "aws_iam_policy_document" "es-domain-firehose-policy" {
  statement {
    sid    = "AllowCognitoES"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${var.Firehose_Role_ARN}"]
    }

    resources = ["*"]
  }
}
