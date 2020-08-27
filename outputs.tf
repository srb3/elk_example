output "network_link" {
  description = "The link to this network resource on google cloud"
  value       = module.vpc.network_link
}

output "monitoring_public_ips" {
  description = "The public ips of the monitoring instances created"
  value       = module.monitoring.public_ips
}

output "monitoring_private_ips" {
  description = "The private ips of the monitoring instances created"
  value       = module.monitoring.private_ips
}
