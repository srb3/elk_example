output "rules" {
  description = "The firewall rules for the cluster, as a map of objects"
  value       = length(var.cluster_rules) > 0 ? var.cluster_rules : local.cluster_rules
}
