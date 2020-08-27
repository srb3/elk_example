variable "image_family" {
  description = "The name of the image family to use for the instances"
  type        = string
  default     = "centos-7"
}

variable "image_project" {
  description = "The name of the image project to use"
  type        = string
  default     = "centos-cloud"
}

variable "pub_ip" {
  description = "Should we assign a public ip address to the instances"
  type        = bool
  default     = false
}

variable "vm_count" {
  description = "The number of instances to create"
  type        = number
  default     = 0
}

variable "name_prefix" {
  description = "The string to prefix to the instances names that are created by this module"
  type        = string
}

variable "tags" {
  description = "A list of network tags to assign to the instances create by this module"
  type        = list(string)
  default     = []
}

variable "labels" {
  description = "A map of labels to set on the instances created by this module"
  type        = map(string)
  default     = {}
}

variable "instance_type" {
  description = "The machine type to use for the instances created by this module"
  type        = string
  default     = "n2-standard-2"
}

variable "volume_size" {
  description = "The size of the volume to create"
  type        = number
  default     = 50
}

variable "volume_type" {
  description = "The type of volume to create"
  type        = string
  default     = "pd-standard" 
}

variable "extra_volume" {
  description = "Should we create an extra disk for this instance"
  type        = bool
  default     = false
}

variable "extra_volume_size" {
  description = "The size of the volume to create"
  type        = number
  default     = 50
}

variable "extra_volume_type" {
  description = "The type of volume to create"
  type        = string
  default     = "pd-standard" 
}

variable "instance_group" {
  description = "Should we create an instance group for each instance this module creates (used for load balancing)"
  type        = bool
  default     = false
}

variable "zones" {
  description = "A list of zones to use for the instances create by this module"
  type        = list(string)
}

variable "subnet_name" {
  description = "The name of the subnet to attach this instance to"
  type        = string
}

variable "ssh_user" {
  description = "The username to associate with the ssh public key"
  type        = string
  default     = "centos"
}

variable "ssh_public_key" {
  description = "The path to an ssh public key to use with the vm_ssh_user variable"
  type        = string
}

variable "startup_script" {
  description = "A string of commands to run at startup, normaly generated from a templatefile"
  type        = string
  default     = ""
}

variable "module_depends_on" {
  description = "List of modules or resources this module depends on."
  type        = list(any)
  default     = []
}
