resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${var.ES_Domain}"
  elasticsearch_version = "6.4"

  cluster_config {
    instance_type  = "${var.Instance_Type}"
    instance_count = "${var.ES_Domain_Size}"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
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

    principals = {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition = {
      test     = "IpAddress"
      variable = "aws:sourceIp"
      values   = ["136.25.13.183/32"]
    }
  }
}s

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

#   statement {
#     sid    = "AuthenticatedESAccess"
#     effect = "Allow"


#     actions = [
#       "es:*",
#     ]


#     principals {
#       type        = "AWS"
#       identifiers = ["${aws_iam_role.cognito-authenticated-users.arn}"]
#     }


#     resources = ["*"]
#   }


#   statement {
#     effect = "Allow"


#     actions = [
#       "es:*",
#     ]


#     principals = {
#       type = "AWS"


#       identifiers = [
#         "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Cognito_AuthenticatedUsersAuth_Role",
#       ]
#     }
#   }
# }

