variable "name" {
  type = string
}

variable "forwarding_rule" {
  type = object({
    port_range            = string
    load_balancing_scheme = string
    ip_protocol           = string
  })
}

variable "backend_service" {
  type = object({
    port_name             = string
    protocol              = string
    load_balancing_scheme = string
    backend = object({
      group = string
    })
  })
}

variable "health_checks" {
  type = list(string)
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}