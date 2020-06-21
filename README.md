# Eager-Locomotive - Security Monitoring Stack 🚂
(Kinesis+ElasticSearch+Kibana Stack for Security Monitoring)

# Overview

  As of March 2019, Amazon Web Services does not have a way of easily analyzing the logs it's services produce. The native AWS solutions are difficult to search, offer little retention capability, and lack robust alerting.

  The purpose of this project is to greatly simplify the process of deploying a basic security monitoring stack on AWS by defining the entire stack as a repeatable `Terraform` plan.

*Features*

* Uses AWS Services
  * ElasticSearch - Scalable cluster for log consolidation
  * Cloudtrail - Management and data events delivered to ElasticSearch
  * Lambda - Delivers JSON blobs to Kinesis streams
  * Kinesis Stream - Scalable event queue for incoming log data
  * Kinesis Firehose - Real-time delivery of events from streams, to ElasticSearch

* Extensible - Adding a log source is simple and scalable
  * Create a new kinesis stream+firehose pair to add new log data
  
* Efficient  - Cloudtrail event is delivered in near real time
  * The entire stack can be deployed in approximately _8_ _minutes_


* Cost Effective - In a high volume environment (70 million events per day) TCO is approximately $34k USD/year (13x m4.large.elasticsearch)
  * ElasticSearch instance size is the key cost control, reduce the cluster size to meet your needs 


## Architecture 

<img src ="./Images/Eager_Locomotive.svg">

## Currently Implemented
* Enable and configure Cloudtrail
* Configure ElasticSearch
* Configure IAM Policies
* Configure S3 Buckets
* Lambda for sending Cloudtrail events to ElasticSearch
* CloudWatch event trigger for sending events to ElasticSearch
* Assign Cloudtrail event triggers

* Enable GuardDuty monitoring - Send new GuardDuty findings to the monitoring stack
  * Create new kinesis stream 
  * Configure cloudwatch event triggers
  
## Pending Implemention

* Enable Amazon Cognito for Kibana Authentication
  
# Deployment


## Requirements

1. An Amazon Web Services Account
2. Terraform 0.12.00 or greater
3. Golang 1.13.0 or greater

