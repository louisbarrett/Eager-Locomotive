#Deploy ElasticSearch
module "ElasticSearch" {
  source            = "./ElasticSearch/"
  ES_Domain         = "eager-locomotive"
  ES_Domain_Size    = 1
  Firehose_Role_ARN = "${module.KinesisToElasticsearch.firehose_arn}"
  Node_Size         = 30
}

module "KinesisToElasticsearch" {
  source                       = "./Kinesis/"
  log_source                   = "cloudtrail"
  elasticsearch_arn            = "${module.ElasticSearch.arn}"
  delivery_failure_bucket_name = "kekstack-failed-logs"
  stream_shard_count           = 3
}

#Enable CloudTrail Logging
module "Cloudtrail" {
  source               = "./CloudTrail/"
  cloudtrail_s3_bucket = "${var.cloudtrail_s3_bucket}"
  count                = 1
}

# Trigger a lambda on the creation of new CloudTrail events
module "S3BucketTrigger" {
  source = "./S3/"
  lambda_arn = "${module.Lambda.lambda_arn}"
  count  = 1
  }

# Lambda to execute when new CloudTrail logs arrive
module "Lambda" {
  source = "./Lambda/"
  stream_name = "incoming-cloudtrail"
  count  = 1
}
