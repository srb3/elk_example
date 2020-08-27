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
    grafana = {
      action  = "allow"
      source_tags = []
      source_ranges  = var.external_source_ranges
      target_tags = ["influxdb"]
      rules   = [
        {
          protocol = "tcp"
          ports    = ["3000","5601"]
        }
      ]
    },
    influxdb = {
      action  = "allow"
      source_tags = []
      source_ranges  = var.internal_source_ranges
      target_tags = ["influxdb"]
      rules   = [
        {
          protocol = "tcp"
          ports = ["8086","8088","8080","3128"]
        }
      ]
    }
  }
}
