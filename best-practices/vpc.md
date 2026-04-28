# VPC Terraform Best Practices

## CIDR Blocks
- Use private RFC 1918 ranges: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`.
- Allocate a /16 for the VPC to allow subnet expansion.
- Subnets: /24 for each AZ tier (public, private, data).
- Avoid overlapping with on-premises or peered VPC ranges.

## Subnet Design
- Deploy at least 2 AZs for high availability.
- Create separate tiers: public (internet-facing), private (app), data (DB).
- Public subnets: `map_public_ip_on_launch = false` — assign Elastic IPs explicitly.

## Internet Connectivity
- One Internet Gateway per VPC (not per AZ).
- One NAT Gateway per AZ for private subnet egress (high availability).
  - Use a single NAT Gateway in dev to reduce cost.
- Attach Elastic IP to each NAT Gateway.

## Routing
- Each subnet tier gets its own route table.
- Public subnets route `0.0.0.0/0` → Internet Gateway.
- Private subnets route `0.0.0.0/0` → NAT Gateway in the same AZ.

## Security Groups
- Default security group: no ingress, no egress.
- Create dedicated security groups per role (app, db, bastion).
- Reference security groups by ID — avoid CIDR-based rules when possible.
- Use `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule`
  (not deprecated inline rules) for Terraform >= 5.x.

## Flow Logs
- Enable VPC Flow Logs for all VPCs in production.
- Log to CloudWatch Logs with a dedicated IAM role.
- Retention: 30 days for dev, 90 days for prod.

## DNS
- `enable_dns_support   = true` (required for ECS, RDS, etc.)
- `enable_dns_hostnames = true` (required for public DNS resolution)
