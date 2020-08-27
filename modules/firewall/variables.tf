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

variable "name_prefix" {
  description = "A string to prepend to the resource name"
  type        = string
}

variable "network" {
  description = "The name of the network to associate these firewall rules with"
  type        = string
}
