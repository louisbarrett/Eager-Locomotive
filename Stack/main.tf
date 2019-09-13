#Deploy ElasticSearch
module "ElasticSearch" {
  source            = "./ElasticSearch/"
  public_ip         = "${var.public_ip}"
  ES_Domain         = "${var.es_domain_name}"
  ES_Domain_Size    = 1
  Firehose_Role_ARN = "${module.CloudTrailKinesisToElasticsearch.firehose_arn}"
  Node_Size         = 30
}

#Kinesis stream for Cloudtrail logs
module "CloudTrailKinesisToElasticsearch" {
  source                       = "./Kinesis/"
  log_source                   = "cloudtrail"
  elasticsearch_arn            = "${module.ElasticSearch.arn}"
  delivery_failure_bucket_name = "${var.failure_s3_bucket}"
  stream_shard_count           = 1
}


# Enable CloudTrail Logging
module "Cloudtrail" {
  source               = "./CloudTrail/"
  cloudtrail_s3_bucket = "${var.es_domain_name}-cloudtrail-logs"
}

# Trigger a lambda on the creation of new CloudTrail events
module "S3BucketTrigger" {
  source               = "./S3/"
  lambda_arn           = "${module.Lambda.lambda_arn}"
  cloudtrail_s3_bucket ="${var.es_domain_name}-cloudtrail-logs"
}

# Lambda to execute when new CloudTrail logs arrive
module "Lambda" {
  source               = "./Lambda/"
  stream_name          = "incoming-cloudtrail"
  cloudtrail_s3_bucket = "${var.cloudtrail_s3_bucket}"
}

module "GuardDuty" {
  source = "./GuardDuty/"
  elasticsearch_arn = "${module.ElasticSearch.arn}"
  delivery_failure_s3_bucket = "${var.failure_s3_bucket}"
}
