resource "google_compute_network" "vnet" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.network_routing_mode
  description             = var.network_description
}

resource "google_compute_network_peering" "peering1" {
  count        = var.network_to_peer_with != null ? 1 : 0
  name         = "${var.name_prefix}-peering1"
  network      = google_compute_network.vnet.id
  peer_network = var.network_to_peer_with
}

resource "google_compute_network_peering" "peering2" {
  count        = var.network_to_peer_with != null ? 1 : 0
  name         = "${var.name_prefix}-peering2"
  network      = var.network_to_peer_with
  peer_network = google_compute_network.vnet.id
}

resource "google_compute_subnetwork" "subnetwork" {
  count                    = length(var.network_subnets)
  name                     = "${var.name_prefix}-${var.network_subnets[count.index].name}"
  network                  = google_compute_network.vnet.name
  ip_cidr_range            = var.network_subnets[count.index].cidr
  private_ip_google_access = var.network_subnets[count.index].private_access
}

resource "google_compute_router" "router" {
  count   = var.enable_nat ? 1 : 0
  name    = "${var.name_prefix}-router"
  network = google_compute_network.vnet.self_link
}

resource "google_compute_address" "nat" {
  count = var.enable_nat ? 1 : 0
  name  ="${var.name_prefix}-cluster-nat-address"
}

resource "google_compute_router_nat" "nat" {
  count                              = var.enable_nat ? 1 : 0
  name                               = "${var.name_prefix}-router-nat"
  router                             = google_compute_router.router[0].name
  region                             = google_compute_router.router[0].region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ips                            = [google_compute_address.nat[0].self_link]
}
