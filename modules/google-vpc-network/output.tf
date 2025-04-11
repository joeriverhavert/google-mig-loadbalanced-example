# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------
output "network" {
  value = google_compute_network.vpc
}

output "subnetworks" {
  value = {
    for key, subnet in google_compute_subnetwork.vpc-subnet :
    key => {
      id        = subnet.id
      name      = subnet.name
      self_link = subnet.self_link
    }
  }
}