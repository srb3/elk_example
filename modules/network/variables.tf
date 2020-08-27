########### Network variables ###################

variable "name_prefix" {
  description = "The name to prefix resources with that are created in this module"
  type        = string
}

variable "network_to_peer_with" {
  description = "The network id of a network we wish to peer with"
  type        = string
  default     = null
}

variable "network_routing_mode" {
  description = "The routing mode to use for the network"
  type        = string
  default     = "REGIONAL"
}

variable "network_description" {
  description = "The description to give our automate cluster network"
  type        = string
  default     = "Automate Cluster Network"
}

variable "auto_create_subnetworks" {
  description = "Should the vpc automate create subnets"
  type        = bool
  default     = false
}

variable "network_subnets" {
  description = "A list of subnets to create for the cluster"
  type = list(object({
    name           = string
    cidr           = string
    private_access = bool
  }))
  default = []
}

variable "enable_nat" {
  description = "Should we enable NAT egress on the cluster nodes"
  type        = bool
  default     = false
}
