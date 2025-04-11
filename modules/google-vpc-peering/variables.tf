# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "name" {
  type        = string
  description = "The name of the VPC peering"
}

variable "network" {
  type        = string
  description = "The self link of the VPC"
}

variable "peer_network" {
  type        = string
  description = "The self link of the peer VPC"
}