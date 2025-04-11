# Google MIG Loadbalanced Example

This Terraform configuration sets up a simple, basic and scalable Google Cloud architecture, including:

- A Managed Instance Group (MIG) to host scalable workloads
- An external HTTP Load Balancer to distribute traffic to the MIG
- Two separate VPCs connected via VPC Peering for network isolation and flexibility
- Custom firewall rules to control and secure traffic flow between resources
- A fully managed Cloud SQL instance to provide a centralized and reliable backend database