# ------------------------------------------------------------------------------
# External reserved IP Address
# ------------------------------------------------------------------------------
resource "google_compute_global_address" "external-address" {
  name = "${var.name}-external-address"
}

# ------------------------------------------------------------------------------
# URL Map
# ------------------------------------------------------------------------------
resource "google_compute_url_map" "compute-url-map" {
  name            = "${var.name}-url-map"
  default_service = google_compute_backend_service.compute-backend-service.id
}

# ------------------------------------------------------------------------------
# HTTP Target Proxy
# ------------------------------------------------------------------------------
resource "google_compute_target_http_proxy" "compute-target-http-proxy" {
  name     = "${var.name}-http-proxy"
  provider = google-beta
  url_map  = google_compute_url_map.compute-url-map.id


  project = var.project
}


# ------------------------------------------------------------------------------
# Forwarding Rule
# ------------------------------------------------------------------------------
resource "google_compute_global_forwarding_rule" "compute-forwarding-rule" {
  name                  = "${var.name}-forwarding-rule"
  target                = google_compute_target_http_proxy.compute-target-http-proxy.id
  port_range            = var.forwarding_rule.port_range
  load_balancing_scheme = var.forwarding_rule.load_balancing_scheme
  ip_protocol           = var.forwarding_rule.ip_protocol

  ip_address = google_compute_global_address.external-address.id
}

# ------------------------------------------------------------------------------
# Backend Service
# ------------------------------------------------------------------------------
resource "google_compute_backend_service" "compute-backend-service" {
  name = "${var.name}-backend-service"

  health_checks = var.health_checks

  port_name             = var.backend_service.port_name
  protocol              = var.backend_service.protocol
  load_balancing_scheme = var.backend_service.load_balancing_scheme

  backend {
    group = var.backend_service.backend.group
  }
}