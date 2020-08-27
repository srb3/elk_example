variable "cluster_rules" {
  description = "List of cluster rule definitions"
  type = map(object({
    action        = string
    source_tags   = list(string)
    source_ranges = list(string)
    target_tags   = list(string)
    rules = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
  default     = {}
}

variable "external_source_ranges" {
  description = "A list of CIDR's to enable access to ssh and dashboards from"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "internal_source_ranges" {
  description = "A list of CIDR's to enable access to the influxdb server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
