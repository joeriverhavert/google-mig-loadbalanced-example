# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "disk" {
  type = object({
    source_image = string
    auto_delete  = bool
    boot         = bool
  })
}

variable "instances" {
  type = object({
    name         = string
    description  = string
    machine_type = string
    replicas = object({
      min = number
      max = number
    })
  })
}

variable "metadata" {
  type = object({
    startup_script = string
  })
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "zone" {
  type = string
}

variable "project" {
  type = string
}