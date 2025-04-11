# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "subnets" {
  type = map(object({
    description   = string
    ip_cidr_range = string
    stack_type    = string
  }))

}

variable "firewall-rules" {
  type = map(object({
    description = string

    allow = object({
      protocol = string
      ports    = list(string)
    })

    source_ranges = list(string)
  }))
}

variable "enable_nat" {
  type    = bool
  default = false
}

variable "region" {
  type = string
}

variable "project" {
  type = string
}