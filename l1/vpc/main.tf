# L1 Resource: aws_vpc
# Creates a single VPC with DNS enabled.
# This is the minimal L1 pattern — combine with aws_subnet, aws_internet_gateway, etc.

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(var.tags, {
    Name = var.name
  })
}
