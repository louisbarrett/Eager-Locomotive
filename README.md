# eager-locomotive
🐸 KEK Stack for  Security Monitoring

As of 3/30/2019 AWS doesn't have a good method of easily analyzing it's native (cloudtrail,elb,vpc flow) logs. The purpose of this project is to simply the process by boot strapping the following:

1. Cloudtrail management events enabled and delivered to S3
2. ElasticSearch Cluster for log consolidation
  * Includes user authentication via Cognito
3. 