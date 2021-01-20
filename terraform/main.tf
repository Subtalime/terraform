# Will not work with Terraform >= 14.0. Downgrade if need be
terraform {
    required_version = ">= 0.13.0,  < 0.14"
    required_providers {
    aws = {
	source  = "hashicorp/aws"
	version = "2.69.0"
    }
  }
}

# Required
provider "aws" {
    region  = var.aws_region
}

data "aws_availability_zones" "available" {
    state = "available"
}


# SSL Certificate
resource "tls_private_key" "domain" {
    algorithm = "RSA"
}

# make it a self signed one for short duration
module "tls_cert" {
    source = "./modules/tls-certificate"

    for_each = var.project

    private_key_pem = tls_private_key.domain.private_key_pem
    dns_zone = "${each.value.dns_name}.${var.domain_name}"
    organization = "My ORG"
}

module "aws_cert" {
    source = "./modules/aws-certificate"

    for_each = var.project

    
    private_key_pem = tls_private_key.domain.private_key_pem
    cert_pem        = module.tls_cert[each.key].cert_pem
}
    

# DNS configuration
resource "aws_route53_zone" "primary" {
    name = var.domain_name
}

module "route_records" {
    source = "./modules/route-record"

    for_each = var.project

    zone_id   = aws_route53_zone.primary.zone_id
    zone_name = aws_route53_zone.primary.name
    records = [ 
	{
	    name = each.value.dns_name
	    type = each.value.dns_record_type
	    alias = {
		name    = module.elb_http[each.key].this_elb_dns_name
		zone_id = module.elb_http[each.key].this_elb_zone_id
	    }
	}
    ]
}


# Virtual private clouds creation per environment
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  for_each = var.project

  cidr = var.cidr_vpc

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, each.value.private_subnets_per_vpc)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, each.value.public_subnets_per_vpc)

  enable_nat_gateway   = false
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
}

/*
resource "aws_subnet" "public_sub" {
    depends_on = [
	for a in keys(var.project): module.vpc[a]
    ]
*/

# Security for the Web-Servers
module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-8080"
  version = "3.12.0"

  for_each = var.project

  name        = "web-server-sg-${each.key}-${each.value.environment}"
  description = "Security group for web-servers with ports open within VPC"
  vpc_id      = module.vpc[each.key].vpc_id

  # Web-Module does not contain SSH by default, add it to be able to use Ansible from SSH-Host networks
  ingress_rules = [ "ssh-tcp" ]
  # add the SSH-Host networks
  ingress_cidr_blocks = concat(module.vpc[each.key].public_subnets_cidr_blocks, var.ssh_access_permit)
  # ingress_cidr_blocks = module.vpc[each.key].public_subnets_cidr_blocks
}

/*

# Security for the Bastion
module "bastion_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-8080"
  version = "3.12.0"

  name        = "web-server-sg-bastion"
  description = "Security group for Bastion-Host"
  vpc_id      = ${aws_default_vpc.default.id}

  ingress_cidr_blocks = var.ssh_access_permit
}

*/

resource "random_string" "lb_id" {
  length  = 4
  special = false
}

# Security for the Load-Balancer
module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = "3.12.0"

  for_each = var.project

  name = "load-balancer-sg-${each.key}-${each.value.environment}"

  description = "Security group for load balancer with ports open to world"
  vpc_id      = module.vpc[each.key].vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
}

# Elastic-Load-Balancer for HTTP Traffic
module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "2.4.0"

  for_each = var.project

  # Comply with ELB name restrictions
  # https://docs.aws.amazon.com/elasticloadbalancing/2012-06-01/APIReference/API_CreateLoadBalancer.html
  # here we want to generate a Route-53 valid name
  name     = trimsuffix(substr(replace(join("-", ["lb", random_string.lb_id.result, each.key, each.value.environment]), "/[^a-zA-Z0-9-]/", ""), 0, 32), "-")
  internal = false

  security_groups = [module.lb_security_group[each.key].this_security_group_id]
  subnets         = module.vpc[each.key].public_subnets

  number_of_instances = length(module.ec2_instances[each.key].instance_id)
  instances           = module.ec2_instances[each.key].instance_id

  # forward traffic from 443 to 8080
  listener = [
  {
    instance_port     = "8080"
    instance_protocol = "HTTP"
    lb_port           = "443"
    lb_protocol       = "HTTPS"
    ssl_certificate_id = module.aws_cert[each.key].id
  }
  ]

  health_check = {
    target              = "HTTP:8080/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }
}

# Store the SSH Key to be used in the Web-Instances
resource "aws_key_pair" "ec2key" {
    key_name = "ssh_key"
    public_key = file(var.public_key_path)
}


# Configure and create the Web-Instances
module "ec2_instances" {
  source = "./modules/aws-instance"

  for_each = var.project

  ami_image          = var.ami_image
  instance_count     = each.value.instances_per_subnet * length(module.vpc[each.key].public_subnets)
  instance_type      = each.value.instance_type
  subnet_ids         = module.vpc[each.key].public_subnets[*]
  security_group_ids = [module.app_security_group[each.key].this_security_group_id]
  ssh_key_name       = aws_key_pair.ec2key.key_name
  private_key_path   = var.private_key_path
  ssh_user           = var.ssh_instance_user
  project_name = each.key
  environment  = each.value.environment
}
