# L2 Module: vpc-module
# Composes a production-ready VPC from L1 resources:
#   - VPC
#   - Public subnets (1 per AZ)
#   - Private subnets (1 per AZ)
#   - Internet Gateway
#   - Elastic IPs + NAT Gateways (1 per AZ in prod, 1 total in dev)
#   - Public + private route tables
#   - VPC Flow Logs → CloudWatch

locals {
  azs             = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_cidrs    = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i)]
  private_cidrs   = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i + 10)]
  nat_count       = var.single_nat_gateway ? 1 : length(local.azs)
  common_tags     = merge(var.tags, { ManagedBy = "terraform" })
}

data "aws_availability_zones" "available" {
  state = "available"
}

# ----- VPC -----
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags, { Name = "${var.name}-vpc" })
}

# ----- Internet Gateway -----
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.common_tags, { Name = "${var.name}-igw" })
}

# ----- Public subnets -----
resource "aws_subnet" "public" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.public_cidrs[count.index]
  availability_zone = local.azs[count.index]
  map_public_ip_on_launch = false
  tags = merge(local.common_tags, {
    Name = "${var.name}-public-${local.azs[count.index]}"
    Tier = "public"
  })
}

# ----- Private subnets -----
resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_cidrs[count.index]
  availability_zone = local.azs[count.index]
  tags = merge(local.common_tags, {
    Name = "${var.name}-private-${local.azs[count.index]}"
    Tier = "private"
  })
}

# ----- Elastic IPs for NAT -----
resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"
  tags   = merge(local.common_tags, { Name = "${var.name}-eip-nat-${count.index}" })
}

# ----- NAT Gateways -----
resource "aws_nat_gateway" "this" {
  count         = local.nat_count
  subnet_id     = aws_subnet.public[count.index].id
  allocation_id = aws_eip.nat[count.index].id
  depends_on    = [aws_internet_gateway.this]
  tags          = merge(local.common_tags, { Name = "${var.name}-nat-${count.index}" })
}

# ----- Public route table -----
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.common_tags, { Name = "${var.name}-rt-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ----- Private route tables (one per AZ) -----
resource "aws_route_table" "private" {
  count  = length(local.azs)
  vpc_id = aws_vpc.this.id
  tags   = merge(local.common_tags, { Name = "${var.name}-rt-private-${count.index}" })
}

resource "aws_route" "private_nat" {
  count                  = length(local.azs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[min(count.index, local.nat_count - 1)].id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# ----- VPC Flow Logs -----
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "/aws/vpc/${var.name}/flow-logs"
  retention_in_days = var.flow_log_retention_days
  tags              = local.common_tags
}

resource "aws_iam_role" "flow_logs" {
  name = "${var.name}-vpc-flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })
  tags = local.common_tags
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.name}-flow-logs-policy"
  role = aws_iam_role.flow_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ]
      Resource = "${aws_cloudwatch_log_group.flow_logs.arn}:*"
    }]
  })
}

resource "aws_flow_log" "this" {
  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.flow_logs.arn
  tags            = merge(local.common_tags, { Name = "${var.name}-flow-log" })
}
