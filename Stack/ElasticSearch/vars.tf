variable "ES_Domain" {
  description = "The name to use when creating the elastic search domain (must be lowercase)"
}
variable "public_ip" {
  
}


variable "ES_Domain_Size" {
  description = "Cluster size of Elastic search domain"
  default     = 5
}

variable "Node_Size" {
  description = "storage  size of each elastic search node"
  default     = 30
}

variable "Instance_Type" {
  description = "storage  size of each elastic search node"
  default     = "t2.medium.elasticsearch"
}

variable "Firehose_Role_ARN" {
  description = "Firehose role to trust connections from"
}
