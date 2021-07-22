output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.kad-msk.bootstrap_brokers_tls
}

output "zookeeper_connect_string" {
  value = aws_msk_cluster.kad-msk.zookeeper_connect_string
}