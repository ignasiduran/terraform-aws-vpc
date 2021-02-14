# terraform-aws-vpc


## Create a basic VPC resources

This Terraform module deploys a VPC resources in AWS.

## backend.tf
```hcl
terraform {
  required_version = "= 0.12.30"

  backend "s3" {
    bucket   = "<bucket_name>"
    key      = "<s3_key>"
    region   = "eu-west-1"
    profile  = "<aws_profile>"
    role_arn = "arn:aws:iam::<aws_account_id>:role/<aws_role_name_to_assume>"
  }
}
```

## providers.tf

```hcl
provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::${var.general.aws_account}:role/${var.general.aws_role_name}"
    session_name = var.general.aws_session_name
  }

  version = ">= 3.28.0"
  region  = var.general.aws_region
  profile = var.general.aws_profile
}
```

## main.tf

```hcl
##########################
# Networking
##########################
module "networking" {
  source                   = "./modules/vpc"
  name                     = var.networking.name
  cidr                     = var.networking.vpc_cidr
  public_subnets           = split(",", var.networking.public_subnets)
  private_subnets          = split(",", var.networking.private_subnets)
  enable_nat_gateway       = var.networking.enable_nat_gateway
  single_nat_gateway       = var.networking.single_nat_gateway
  one_nat_gateway_per_az   = var.networking.one_nat_gateway_per_az
  enable_dns_hostnames     = var.networking.enable_dns_hostnames
  enable_dns_support       = var.networking.enable_dns_support
  dhcp_options_domain_name = var.networking.dhcp_options_domain_name
  tags                     = var.tags
  private_subnet_tags      = {}
  public_subnet_tags       = {}
}
```

## variables.tf

```hcl
##########################
# General variables
##########################
variable "general" {
  description = "General variables"
  type        = map(string)
  default = {
    aws_account      = "<aws_account_is>"
    aws_region       = "eu-west-1"
    aws_profile      = "<aws_profile>"
    aws_role_name    = "<aws_role_name_to_assume>"
    aws_session_name = "terraform"
  }
}

##########################
# General Tags
##########################
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Managedby   = "Terraform"
    Platform    = "<name>"
    Environment = "test"
  }
}

##########################
# Networking - VPC, Subnets, Route tables, DHCP Options, IG, NAT GW
##########################
variable "networking" {
  description = "Networking variables"
  type        = map(string)
  default = {
    name                     = "<name>"
    vpc_cidr                 = "10.20.0.0/16"
    public_subnets           = "10.20.1.0/24,10.20.2.0/24,10.20.3.0/24"
    private_subnets          = "10.20.11.0/24,10.20.12.0/24,10.20.13.0/24"
    enable_nat_gateway       = true
    single_nat_gateway       = true
    one_nat_gateway_per_az   = false
    enable_dns_hostnames     = true
    enable_dns_support       = true
    dhcp_options_domain_name = "<name.test>"
  }
}
```