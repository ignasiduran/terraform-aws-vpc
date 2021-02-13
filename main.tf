######
# VPC
######
resource "aws_vpc" "this" {

  cidr_block           = var.cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge({ "Name" = var.name }, var.tags, var.vpc_tags)
}

###################
# DHCP Options Set
###################
resource "aws_vpc_dhcp_options" "this" {
  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge({ "Name" = var.name }, var.tags, var.dhcp_options_tags)
}

###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this.id
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge({ "Name" = var.name }, var.tags, var.igw_tags)
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 && false == var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs) ? length(var.public_subnets) : 0

  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge({ "Name" = format("%s-public-%s", var.name, element(var.azs, count.index), ) }, var.tags, var.public_subnet_tags, )
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge({ "Name" = format("%s-private-%s", var.name, element(var.azs, count.index), ) }, var.tags, var.private_subnet_tags, )
}

##############
# NAT Gateway
##############

locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : 0
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  vpc = true

  tags = merge({ "Name" = format("%s-%s", var.name, element(var.azs, var.single_nat_gateway ? 0 : count.index), ) }, var.tags, var.nat_eip_tags, )
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    aws_eip.nat.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  subnet_id = element(
    aws_subnet.public.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge({ "Name" = format("%s-%s", var.name, element(var.azs, var.single_nat_gateway ? 0 : count.index), ) }, var.tags, var.nat_gateway_tags, )

  depends_on = [aws_internet_gateway.this]
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge({ "Name" = format("%s-public", var.name, ) }, var.tags, var.public_route_table_tags, )
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "private" {
  count = length(var.private_subnets) > 0 ? local.nat_gateway_count : 0

  vpc_id = aws_vpc.this.id

  tags = merge({ "Name" = format("%s-private", var.name, ) }, var.tags, var.private_route_table_tags, )

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = [propagating_vgws]
  }
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.this.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private.*.id,
    var.single_nat_gateway ? 0 : count.index,
  )
}
