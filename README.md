# Eager-Locomotive - Security Monitoring Stack 🚂
(Kinesis+ElasticSearch+Kibana Stack for Security Monitoring)

## Overview

  As of March 2019, Amazon Web Services does not have a way of easily analyzing the logs it's services produce. The native AWS solutions are difficult to search, offer little retention capability, and lacks robust alerting.

  The purpose of this project is to greatly simplify the process of deploying a basic security monitoring stack on AWS by defining the entire stack as a repeatable `Terraform` plan.

1. Cloudtrail management events enabled and delivered to S3
2. ElasticSearch Cluster for log consolidation
3. Kinesis Stream for buffering incoming eents
4. Kinesis Firehose for delivering Cloudtrail events to ElasticSearch

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


## To-Do

* Enable GuardDuty monitoring
 * Send new GuardDuty findings to the monitoring stack
  * create new kinesis stream 
  * configure cloudwatch event triggers
