locals {
  working_dir = "${var.cluster_tmp_path}/${var.cluster_working_folder}"
}

resource "null_resource" "cluster" {

  triggers = {
    value = md5(var.cluster_script)
  }

  count = var.cluster_count
  connection {
    host                = var.cluster_ips[count.index]
    user                = var.cluster_ssh_user
    private_key         = file(var.cluster_ssh_private_key)
    script_path         = "${var.cluster_tmp_path}/${var.cluster_ips[count.index]}-${var.cluster_working_folder}_tf_inline_script_connect_gcp.sh"
    type                = "ssh"

    bastion_host        = var.bastion_ip
    bastion_user        = var.bastion_ssh_user
    bastion_private_key = var.bastion_ssh_private_key != null ? file(var.bastion_ssh_private_key) : null
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.working_dir}",
     ]
  }

  provisioner "file" {
    content     = var.cluster_script
    destination = "${local.working_dir}/cluster.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.ssh_user_sudo_password} | ${var.sudo_cmd} -S bash -ex ${local.working_dir}/cluster.sh",
     ]
  }
  depends_on = [null_resource.module_depends_on, null_resource.module_depends_on_ex]
}

resource "null_resource" "module_depends_on" {
  triggers = {
    value = length(var.module_depends_on)
  }
}

resource "null_resource" "module_depends_on_ex" {
  triggers = {
    value = length(var.module_depends_on_ex)
  }
}
