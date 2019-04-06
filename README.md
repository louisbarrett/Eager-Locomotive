# eager-locomotive - Kinesis ElasticSearch Kibana Monitoring Stack
Stack for  Security Monitoring

As of 3/30/2019 AWS doesn't have a good method of easily analyzing it's native (cloudtrail,elb,vpc flow) logs. The purpose of this project is to simply the process by boot strapping the following:

1. Cloudtrail management events enabled and delivered to S3
2. ElasticSearch Cluster for log consolidation
3. Kinesis Stream for buffering incoming eents
4. Kinesis Firehose for delivering Cloudtrail events to ElasticSearch


## To-Do

* Enable GuardDuty monitoring
 * Send new GuardDuty findings to the monitoring stack
  * create new kinesis stream 
  * configure cloudwatch event triggers
