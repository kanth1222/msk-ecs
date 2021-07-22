// locals {
//   server_properties = join("\n", [for k, v in var.server_properties : format("%s = %s", k, v)])
// }

data "aws_availability_zones" "azs" {
  state = "available"
}



resource "aws_cloudwatch_log_group" "msk-logs" {
  name = "msk_broker_logs"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "msk-broker-logs-bucket-cp-${var.cluster-env}"
  acl    = "private"
}


resource "aws_s3_bucket" "kafka-cms" {
  bucket = "kafka-cms-${var.cluster-env}"
  acl    = "private"
}

resource "aws_kms_key" "kms" {
  description = "kad-msk-${var.cluster-env}"
}
resource "aws_security_group" "kad-msk" {
  name        = "kad-msk-${var.cluster-env}"
  description = "kad-msk security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["12.185.117.80/29","192.168.64.0/18","76.85.100.54/32","68.109.65.20/32","64.113.23.158/32"]
  }
   ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "22"
    cidr_blocks = ["192.168.64.0/18"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_msk_configuration" "kad-msk" {
   name             = var.msk_configuration_name
  kafka_versions    = [var.msk_kafka_version]
  // server_properties = local.server_properties
    server_properties  = <<PROPERTIES
  auto.create.topics.enable = true
  default.replication.factor =  2
  min.insync.replicas = 2
  num.io.threads = 8
  num.network.threads = 5
  num.partitions = 1
  num.replica.fetchers = 2
  replica.lag.time.max.ms = 30000
  socket.receive.buffer.bytes = 102400
  socket.request.max.bytes = 104857600
  socket.send.buffer.bytes = 102400
  unclean.leader.election.enable = true
  zookeeper.session.timeout.ms = 18000
  message.max.bytes = 2147483647
  replica.fetch.max.bytes = 2147483647
  replica.fetch.response.max.bytes = 2147483647

PROPERTIES

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_msk_cluster" "kad-msk" {
  cluster_name           = "kad-msk-${var.cluster-env}"
  enhanced_monitoring    = "DEFAULT"
  kafka_version          = var.msk_kafka_version
  number_of_broker_nodes = var.msk_number_of_brokers

  broker_node_group_info {
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.kad-msk.id]
    ebs_volume_size = var.msk_ebs_volume_size
    instance_type   = var.msk_instance_type
  }

   open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
      in_cluster    = true
    }
     encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk-logs.name
      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.bucket.id
        prefix  = "logs/msk-"
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.kad-msk.arn
    revision = aws_msk_configuration.kad-msk.latest_revision
  }
}
