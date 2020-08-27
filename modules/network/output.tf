locals {
  subnets = length(google_compute_subnetwork.subnetwork) > 0 ? [for network in google_compute_subnetwork.subnetwork : network.name] : [""]
}

output "network_name" {
  description = "The network name created by this module"
  value       = google_compute_network.vnet.name
}

output "network_link" {
  description = "The link to this network resource on google cloud"
  value       = google_compute_network.vnet.self_link
}

output "subnet_names" {
  description = "The names of the subnets being created"
  value       = local.subnets
}

output "nat_address" {
  description = "The address of the nat interface for egress traffic"
  value       = length(google_compute_address.nat) > 0 ? google_compute_address.nat[0].address : null
}
