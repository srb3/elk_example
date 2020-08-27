resource "google_compute_firewall" "cluster" {
  for_each      = var.cluster_rules
  name          = "${var.name_prefix}-${each.key}"
  network       = var.network
  source_tags   = length(each.value.source_tags) > 0 ? each.value.source_tags : null
  target_tags   = length(each.value.target_tags) > 0 ? each.value.target_tags : null
  source_ranges = length(each.value.source_ranges) > 0 ? each.value.source_ranges : null

  dynamic "allow" {
    for_each = [for rule in each.value.rules : rule if each.value.action == "allow"]
    iterator = rule
    content {
      protocol = rule.value.protocol
      ports    = rule.value.ports
    }
  }
}
