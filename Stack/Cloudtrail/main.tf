
data "aws_iam_policy_document" "CloudTrailBucketPolicy" {
  statement {
    sid     = "CloudTrailS3Write"
    effect  = "Allow"
    actions = ["s3:PutObject"]

    principals  {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["arn:aws:s3:::${var.cloudtrail_s3_bucket}/*"]
  }

  statement {
    sid     = "CloudTrailS3GetAcl"
    effect  = "Allow"
    actions = ["s3:GetBucketAcl"]

    principals  {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["arn:aws:s3:::${var.cloudtrail_s3_bucket}"]
  }
}
# Main cloudtrail resource
resource "aws_cloudtrail" "ManagementEvents" {
  name                  = "${var.cloudtrail_s3_bucket}"
  s3_bucket_name        = "${aws_s3_bucket.CloudTrail.id}"
  is_multi_region_trail = true
}

# Default Cloudtrail logging bucket
resource "aws_s3_bucket" "CloudTrail" {
  bucket        = "${var.cloudtrail_s3_bucket}"
  policy        = "${data.aws_iam_policy_document.CloudTrailBucketPolicy.json}"
  force_destroy = true

  
}

#Basic CloudTrail bucket policy

