# ------------------------------------------------------------------------------
# Service Account
# ------------------------------------------------------------------------------
resource "google_service_account" "mig-service-account" {
  account_id   = "${var.name}-sa"
  display_name = "Service account for ${var.name}"
}

# ------------------------------------------------------------------------------
# Managed Instance Group Template
# ------------------------------------------------------------------------------
resource "google_compute_instance_template" "mig-template" {
  name        = "${var.name}-template"
  description = "${var.description}-template"


  instance_description = var.instances.description
  machine_type         = var.instances.machine_type

  disk {
    source_image = var.disk.source_image
    auto_delete  = var.disk.auto_delete
    boot         = var.disk.boot
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  metadata_startup_script = var.metadata.startup_script

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.mig-service-account.email
    scopes = ["cloud-platform"]
  }
}

# ------------------------------------------------------------------------------
# Managed Instance Group
# ------------------------------------------------------------------------------
resource "google_compute_instance_group_manager" "mig-manager" {
  name        = var.name
  description = "${var.description} manager"

  base_instance_name = var.instances.name

  named_port {
    port = 80
    name = "http"
  }

  version {
    instance_template = google_compute_instance_template.mig-template.self_link_unique
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.mig-autohealing.id
    initial_delay_sec = 300
  }

  zone = var.zone
}

# ------------------------------------------------------------------------------
# Autoscaler
# ------------------------------------------------------------------------------
resource "google_compute_autoscaler" "mig-autoscaler" {
  name   = "${var.name}-autoscaler"
  target = google_compute_instance_group_manager.mig-manager.id

  autoscaling_policy {
    min_replicas = var.instances.replicas.min
    max_replicas = var.instances.replicas.max

    cpu_utilization {
      target = 0.6
    }

    cooldown_period = 60
  }

  zone = var.zone
}

# ------------------------------------------------------------------------------
# Health check
# ------------------------------------------------------------------------------
resource "google_compute_health_check" "mig-autohealing" {
  name                = "${var.name}-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}