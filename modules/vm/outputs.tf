output "public_ips" {
  description = "The public ips of the instances created"
  value       = [ for add in google_compute_address.vm.*.address : tostring(add) ]
}

output "private_ips" {
  description = "The private ips of the instances created"
  value       = google_compute_instance.vm.*.network_interface.0.network_ip
}

output "instances" {
  description = "List of self-links for compute instances"
  value       = google_compute_instance.vm.*.self_link
}

output "instance_groups" {
  description = "List of instance groups for compute instances"
  value       = [ for g in google_compute_instance_group.ig.*.self_link : { group = g } ]
}
