########### Tag variables #######################

variable "tag_contact" {
  description = "The email address of the main point of contact for the cluster"
  type        = string
}

variable "tag_dept" {
  description = "The department this deployment belongs to"
  type        = string
}

variable "tag_name" {
  description = "A name to give as a prefix to the cloud resources created"
  type        = string
  default     = "A2"
}

variable "tag_project" {
  description = "The name to give this deployment"
  type        = string
}

########### GCP Provider variables ###############

variable "gcp_project" {
  description = "The name of the gcp project to use"
  type        = string
}

variable "gcp_region" {
  description = "The name of the gcp region to use"
  type        = string
}

########### Network variables ###################

variable "enable_nat" {
  description = "Should we enable NAT egress on the cluster nodes"
  type        = bool
  default     = true
}

variable "network_to_peer_with" {
  description = "The network self link of a network we wish to peer with"
  type        = string
  default     = null
}

variable "subnets" {
  description = "A list of subnets to create for the cluster"
  type = list(object({
    name           = string
    cidr           = string
    private_access = bool
  }))
  default = [
    {
      name           = "monitoring-subnet"
      cidr           = "10.8.1.0/24"
      private_access = true
    }
  ]
}

########### Firewall module variables ###########

variable "firewall_rules" {
  description = "A map of rules to describe cluster communication rules"
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
  default = {}
}

variable "external_source_ranges" {
  description = "A list of CIDR's to allow traffic to the monitoring server ssh and dashboards"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "internal_source_ranges" {
  description = "A list of CIDR's to allow internal traffic to the monitoring servers databases"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

########### Cluster host variables ##############

variable "cluster_ssh_user" {
  description = "The ssh username to use for connection to the cluster hosts through the bastion host"
  type        = string
  default     = "centos"
}

variable "cluster_ssh_public_key" {
  description = "The path to the ssh public key to use for the bastion host"
  type        = string
}

variable "cluster_ssh_private_key" {
  description = "The path to the ssh private key to use for the bastion host"
  type        = string
}

########### Monitoring variables ##############

variable "monitoring_count" {
  description = "The number of hosts to create"
  type        = number
  default     = 1
}

variable "monitoring_instance_group" {
  description = "Should we create an instnace group for the monitoring servers (one ig per zone)"
  type        = bool
  default     = false
}

variable "monitoring_tags" {
  description = "A list of network tags to assign to this host"
  type        = list(string)
  default     = ["base", "grafana", "influxdb"]
}

variable "monitoring_pub_ip" {
  description = "Should the server have a public ip"
  type        = bool
  default     = true
}

variable "monitoring_instance_type" {
  description = "The type of instnace to create"
  type        = string
  default     = "n2-standard-2"
}

variable "monitoring_volume_size" {
  description = "The size of the volume to create (GB)"
  type        = number
  default     = 100
}

variable "monitoring_volume_type" {
  description = "The type of volume to create"
  type        = string
  default     = "pd-standard"
}

variable "monitoring_extra_volume" {
  description = "Should we mount an extra volume for this instance"
  type        = bool
  default     = false
}

variable "monitoring_extra_volume_type" {
  description = "The type of extra volume to create"
  type        = string
  default     = "pd-standard"
}

variable "monitoring_extra_volume_size" {
  description = "The size of the extra volume to create (GB)"
  type        = number
  default     = 200
}

variable "elasticsearch_heap" {
  description = "The ammount of memory to assign to elasticsearch"
  type        = string
  default     = "4"
}

variable "logstash_heap" {
  description = "The ammount of memory to assign to logstash"
  type        = string
  default     = "2"
}
