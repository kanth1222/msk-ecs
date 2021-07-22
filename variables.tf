variable "vpc_id" {
  description = "VPC to deploy resources"
}


variable "subnet_ids" {
  description = "VPC Subnets"
  type        = list(string)
}

variable "msk_instance_type" {
  description = "MSK cluster instance type"
}

variable "msk_kafka_version" {
  description = "MSK kafka version"
  // type        = "string"
}

variable "msk_number_of_brokers" {
  description = "MSK kafka number of brokers"
}

variable "msk_ebs_volume_size" {
  description = "MSK kafka broker volume size"
}

variable "msk_encryption_data_in_transit" {
  description = "MSK encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS_PLAINTEXT, and PLAINTEXT"
}

// variable "msk_min_in_sync_replicas" {
//   description = "Minimum number of in-sync replicas (ISRs) that must be available for the producer to successfully send messages to a partition"
// }

// variable "msk_default_replication_factor" {
//   description = "Default replication factors for automatically created topics."
// }

variable "msk_configuration_name" {
  description = "MSK Configuration name. This needs to be set to a new value for new deployments as currently AWS doesn't allow destroying MSK configurations"
}
variable "cluster-env"{
  description = "env of the cluster"
}

variable "server_properties" {
  description = "A map of the contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)."
  type        = map(string)
  default     =  {}
}