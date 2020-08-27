data "google_compute_image" "vm" {
  family  = var.image_family
  project = var.image_project
}

resource "google_compute_disk" "vm" {
  count = var.extra_volume == true ? var.vm_count : 0
  name  = format("${var.name_prefix}-vol-%02d",count.index + 1)
  zone  = var.zones[count.index]
  type  = var.extra_volume_type
  size  = var.extra_volume_size
}

resource "google_compute_address" "vm" {
  count = var.pub_ip == true ? var.vm_count : 0
  name  = format("${var.name_prefix}-%02d",count.index + 1)

  depends_on = [null_resource.module_depends_on]
}

locals {
  disks = { for x in google_compute_disk.vm.*.self_link :
    "${index(google_compute_disk.vm.*.self_link, x)}" => [
      "${x}"
    ]
  }
}

resource "google_compute_instance_group" "ig" {
  count        = var.instance_group == true ? var.vm_count : 0
  name         = format("${var.name_prefix}-ig-%02d",count.index + 1)
  zone         = var.zones[count.index]
  instances = [
    google_compute_instance.vm[count.index].self_link
  ]

  named_port {
    name = "https"
    port = "443"
  }
}

resource "google_compute_instance" "vm" {
  count        = var.vm_count
  name         = format("${var.name_prefix}-%02d",count.index + 1)
  tags         = var.tags
  labels       = var.labels
  machine_type = var.instance_type
  zone         = var.zones[count.index]

  boot_disk {
    initialize_params {
      size  = var.volume_size
      type  = var.volume_type
      image = data.google_compute_image.vm.self_link
    }
  }

  network_interface {
    subnetwork = var.subnet_name
    dynamic "access_config" {
      for_each = toset(google_compute_address.vm.*.address)
      content {
        nat_ip = access_config.value
      }
    }
  }

  dynamic "attached_disk" {
    for_each = length(local.disks) > 0 ? [for disk in lookup(local.disks,count.index) : disk if var.extra_volume == true ] : []
    content {
      source =  attached_disk.value
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key)}"
    startup-script = var.startup_script != "" ? var.startup_script : null
  }

  depends_on = [null_resource.module_depends_on]
}

resource "null_resource" "module_depends_on" {

  triggers = {
    value = length(var.module_depends_on)
  }
}
