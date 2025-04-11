# ------------------------------------------------------------------------------
# Vpc & Subnets
# ------------------------------------------------------------------------------
resource "google_compute_network" "vpc" {
  name        = var.name
  description = var.description

  auto_create_subnetworks = false

  project = var.project
}

resource "google_compute_subnetwork" "vpc-subnet" {
  for_each = var.subnets

  name        = each.key
  description = each.value.description

  network       = google_compute_network.vpc.id
  ip_cidr_range = each.value.ip_cidr_range

  stack_type = "IPV4_ONLY"

  private_ip_google_access = true

  region  = var.region
  project = var.project
}

# ------------------------------------------------------------------------------
# Router & NAT
# ------------------------------------------------------------------------------
resource "google_compute_router" "vpc-router" {
  count = var.enable_nat ? 1 : 0

  name    = "${var.name}-router"
  network = google_compute_network.vpc.name
}

resource "google_compute_router_nat" "vpc-router-nat" {
  count = var.enable_nat ? 1 : 0

  name                               = "${var.name}-nat"
  router                             = google_compute_router.vpc-router[count.index].name
  region                             = google_compute_router.vpc-router[count.index].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ------------------------------------------------------------------------------
# Firewall rules
# ------------------------------------------------------------------------------  
resource "google_compute_firewall" "allow-http" {
  for_each = var.firewall-rules

  name        = each.key
  description = each.value.description
  network     = google_compute_network.vpc.id

  allow {
    protocol = each.value.allow.protocol
    ports    = each.value.allow.ports
  }

  source_ranges = each.value.source_ranges
}
