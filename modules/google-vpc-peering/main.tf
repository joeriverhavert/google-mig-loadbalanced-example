resource "google_compute_network_peering" "peering-nprod-frontend-to-backend" {
  name         = var.name
  network      = var.network
  peer_network = var.peer_network
}

resource "google_compute_network_peering" "peering-nprod-backend-to-frontend" {
  name         = "${var.name}-reverse"
  network      = var.peer_network
  peer_network = var.network
}