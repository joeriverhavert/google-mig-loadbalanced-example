# ------------------------------------------------------------------------------
# Frontend VPC -> Webserver MIG
# ------------------------------------------------------------------------------  
module "nprod-frontend-vpc" {
  source = "./modules/google-vpc-network"

  name        = "nprod-frontend"
  description = "Non-production frontend Virtual Private Network."

  enable_nat = true

  subnets = {
    "nprod-frontend-subnet" = {
      description   = "Non-production frontend subnet."
      ip_cidr_range = "172.16.0.0/18"
      stack_type    = "IPV4_ONLY"
    }
  }

  firewall-rules = {
    "allow-http" = {
      description = "Allow HTTP traffic"

      allow = {
        protocol = "TCP"
        ports    = ["80"]
      }

      source_ranges = ["0.0.0.0/0"]
    },

    "allow-ssh-cloudshell" = {
      description = "Allow ssh connections from the cloudshell."

      allow = {
        protocol = "TCP"
        ports    = ["22"]
      }

      source_ranges = ["35.235.240.0/20"]
    }
  }

  region  = var.region
  project = var.project
}

# ------------------------------------------------------------------------------
# Backend VPC -> Cloud SQL
# ------------------------------------------------------------------------------ 
module "nprod-backend-vpc" {
  source = "./modules/google-vpc-network"

  name        = "nprod-backend"
  description = "Non-production backend Virtual Private Network."

  enable_nat = false

  subnets = {
    "nprod-backend-subnet" = {
      description   = "Non-production backend subnet"
      ip_cidr_range = "172.18.0.0/18"
      stack_type    = "IPV4_ONLY"
    }
  }

  firewall-rules = {
    "allow-frontend-vpc-traffic" = {
      description = "Allow TCP traffic from the frontend VPC."

      allow = {
        protocol = "TCP"
        ports    = ["5432"]
      }

      source_ranges = ["172.16.0.0/18"]
    }
  }

  region  = var.region
  project = var.project
}

# ------------------------------------------------------------------------------
# VPC Peering
# ------------------------------------------------------------------------------ 
module "vpc-peering" {
  source = "./modules/google-vpc-peering"

  name         = "peering-nprod-frontend-and-backend"
  network      = module.nprod-frontend-vpc.network.self_link
  peer_network = module.nprod-backend-vpc.network.self_link
}

# ------------------------------------------------------------------------------
# Managed Instance Group
# ------------------------------------------------------------------------------
module "vpc-managed-instance-group" {
  source = "./modules/google-managed-instance-group"

  name        = "nprod-frontend-http-mig"
  description = "Non-production frontend http managed instance group"

  network    = module.nprod-frontend-vpc.network.name
  subnetwork = module.nprod-frontend-vpc.subnetworks["nprod-frontend-subnet"].name

  disk = {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  instances = {
    name         = "nprod-frontend-instance"
    description  = "Non-production frontend instance"
    machine_type = "e2-small"
    replicas = {
      min = 1
      max = 3
    }
  }

  metadata = {
    startup_script = <<EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl enable --now nginx
    EOF
  }

  zone    = var.zone
  project = var.project
}

# ------------------------------------------------------------------------------
# Load Balancer
# ------------------------------------------------------------------------------
module "vpc-external-loadbalancer" {
  source = "./modules/google-external-http-loadbalanacer"

  name = "nprod-frontend-lb"

  forwarding_rule = {
    port_range            = "80"
    load_balancing_scheme = "EXTERNAL"
    ip_protocol           = "TCP"
  }

  backend_service = {
    port_name             = "http"
    protocol              = "HTTP"
    load_balancing_scheme = "EXTERNAL"

    backend = {
      group = module.vpc-managed-instance-group.instance_group
    }
  }

  health_checks = [module.vpc-managed-instance-group.health_check.self_link]

  region  = var.region
  project = var.project
}