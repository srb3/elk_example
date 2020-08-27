terraform {
  required_version = "> 0.12.0"
}

provider "google" {
  project                 = var.gcp_project
  region                  = var.gcp_region
}

########### infrastructure setup #################

resource "random_id" "random" {
  byte_length = 4
}

data "google_compute_image" "centos" {
  family  = "centos-7"
  project = "centos-cloud"
}

data "google_compute_zones" "available" {
  project = var.gcp_project
  region  = var.gcp_region
}

locals {
  name_prefix           = "${var.tag_name}-${random_id.random.hex}"
  monitoring_prefix     = "${local.name_prefix}-vm-monitoring"
  labels                = {
    x-dept    = var.tag_dept
    x-project = var.tag_project
    x-contact = var.tag_contact
  }
}

module "vpc" {
  source               = "./modules/network"
  name_prefix          = local.name_prefix
  network_description  = "monitoring network"
  network_subnets      = var.subnets
  enable_nat           = var.enable_nat
  network_to_peer_with = var.network_to_peer_with
}

module "firewall_rules" {
  source                 = "./modules/firewall_rules"
  cluster_rules          = var.firewall_rules
  external_source_ranges = var.external_source_ranges
  internal_source_ranges = var.internal_source_ranges
}

module "firewall" { 
  source                = "./modules/firewall"
  name_prefix           = local.name_prefix
  network               = module.vpc.network_name
  cluster_rules         = module.firewall_rules.rules
}

module "monitoring" {
  source            = "./modules/vm"
  vm_count          = var.monitoring_count
  name_prefix       = local.monitoring_prefix
  instance_group    = var.monitoring_instance_group
  tags              = var.monitoring_tags
  pub_ip            = var.monitoring_pub_ip
  labels            = local.labels
  instance_type     = var.monitoring_instance_type
  volume_size       = var.monitoring_volume_size
  volume_type       = var.monitoring_volume_type
  zones             = data.google_compute_zones.available.names
  subnet_name       = module.vpc.subnet_names[0]
  ssh_user          = var.cluster_ssh_user
  ssh_public_key    = var.cluster_ssh_public_key
  extra_volume      = var.monitoring_extra_volume
  extra_volume_type = var.monitoring_extra_volume_type
  extra_volume_size = var.monitoring_extra_volume_size
  module_depends_on = [module.firewall]
}

module "monitoring_setup" {
  source                 = "./modules/monitoring"
  target_count           = var.monitoring_count
  target_ips             = module.monitoring.public_ips
  target_ssh_user        = var.cluster_ssh_user
  target_ssh_private_key = var.cluster_ssh_private_key
  elasticsearch_heap     = var.elasticsearch_heap
  logstash_heap          = var.logstash_heap
  module_depends_on      = [module.monitoring]
}
