variable "elasticsearch_heap" {
  description = "The ammount of heap to allocate to elasticsearch"
  type        = string
  default     = "4"
}

variable "logstash_heap" {
  description = "The ammount of heap to allocate to logstash"
  type        = string
  default     = "2"
}

variable "tmp_path" {
  description = "The location of the main temp directory"
  type        = string
  default     = "/var/tmp"
}

variable "java_package" {
  description = "The name of the java package"
  type        = string
  default     = "java-11-openjdk" 
}

variable "elasticsearch_package" {
  description = "The name of the elasticsearch package"
  type        = string
  default     = "elasticsearch" 
}

variable "logstash_package" {
  description = "The name of the logstash package"
  type        = string
  default     = "logstash" 
}

variable "monitoring_working_directory" {
  description = "The directory for setting up the monitoring server"
  type        = string
  default     = "monitoring"
}

variable "target_count" {
  description = "The number of target hosts to connect to"
  type        = number
  default     = 0
}

variable "target_ips" {
  description = "The hostnames or addresses of the vms to connect to"
  type        = list(string)
  default     = []
}

variable "target_ssh_user" {
  description = "The name of the ssh user"
  type        = string
  default     = "centos"
}

variable "target_ssh_private_key" {
  description = "The ssh private key path for the ssh access key for the cluster hosts"
  type        = string
}

variable "module_depends_on" {
  description = "List of modules or resources this module depends on."
  type        = list(any)
  default     = []
}
