locals {
  elasticsearch_content = templatefile("${path.module}/templates/elasticsearch.repo",{})
  repos = {
    "elasticsearch.repo" = local.elasticsearch_content
  }
  install_file = templatefile("${path.module}/templates/install.sh", {
    tmp_path                     = var.tmp_path
    elasticsearch_heap           = var.elasticsearch_heap
    logstash_heap                = var.logstash_heap
    yum_repos                    = local.repos
    yum_packages                 = [var.java_package, var.elasticsearch_package, var.logstash_package]
  })
}

module "elk_install" {
  source                  = "../cluster_connect"
  cluster_count           = var.target_count
  cluster_ips             = var.target_ips
  cluster_ssh_user        = var.target_ssh_user
  cluster_ssh_private_key = var.target_ssh_private_key
  cluster_script          = local.install_file
  cluster_tmp_path        = var.tmp_path
  cluster_working_folder  = var.monitoring_working_directory
  module_depends_on       = [var.module_depends_on]
}
