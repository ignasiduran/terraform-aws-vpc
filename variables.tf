######
# General variables
######
variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = "internal"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    managedby = "terraform"
  }
}

######
# VPC
######
variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

###################
# DHCP Options Set
###################
variable "dhcp_options_domain_name" {
  description = "Specifies DNS name for DHCP options set"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

variable "dhcp_options_ntp_servers" {
  description = "Specify a list of NTP servers for DHCP options set"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_name_servers" {
  description = "Specify a list of netbios servers for DHCP options set"
  type        = list(string)
  default     = []
}

variable "dhcp_options_netbios_node_type" {
  description = "Specify netbios node_type for DHCP options set"
  type        = string
  default     = ""
}

variable "dhcp_options_tags" {
  description = "Additional tags for the DHCP Options"
  type        = map(string)
  default     = {}
}

###################
# Internet Gateway
###################
variable "igw_tags" {
  description = "Additional tags for the IGW"
  type        = map(string)
  default     = {}
}

################
# Subnets
################
variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}


variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address"
  type        = bool
  default     = false
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnet"
  type        = map(string)
  default     = {}
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnet"
  type        = map(string)
  default     = {}
}

##############
# NAT Gateway
##############
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = true
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = false
}

variable "nat_eip_tags" {
  description = "Additional tags for the NAT GW EIP"
  type        = map(string)
  default     = {}
}

variable "nat_gateway_tags" {
  description = "Additional tags for the NAT GW"
  type        = map(string)
  default     = {}
}

################
# Publiс routes
################
variable "public_route_table_tags" {
  description = "Additional tags for the public routes"
  type        = map(string)
  default     = {}
}

################
# Private routes
################
variable "private_route_table_tags" {
  description = "Additional tags for the private routes"
  type        = map(string)
  default     = {}
}

