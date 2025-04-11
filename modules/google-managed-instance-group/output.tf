# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------
output "health_check" {
  value = google_compute_health_check.mig-autohealing
}

output "instance_group" {
  value = google_compute_instance_group_manager.mig-manager.instance_group
}