locals {
  cluster_rules = {
    base = {
      action  = "allow"
      source_tags   = []
      source_ranges = var.external_source_ranges
      target_tags   = ["base"]
      rules   = [
        {
          protocol = "tcp"
          ports    = ["22"]
        }
      ]
    },
    kibana = {
      action  = "allow"
      source_tags = []
      source_ranges  = var.external_source_ranges
      target_tags = ["kibana"]
      rules   = [
        {
          protocol = "tcp"
          ports    = ["5601"]
        }
      ]
    },
    logstash = {
      action  = "allow"
      source_tags = []
      source_ranges  = var.internal_source_ranges
      target_tags = ["logstash"]
      rules   = [
        {
          protocol = "tcp"
          ports = ["8080"]
        }
      ]
    }
  }
}
