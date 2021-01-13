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

  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
}


# Security for the Web-Servers
module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "3.12.0"

  for_each = var.project

  name        = "web-server-sg-${each.key}-${each.value.environment}"
  description = "Security group for web-servers with ports open within VPC"
  vpc_id      = module.vpc[each.key].vpc_id

  #  ingress_cidr_blocks = module.vpc[each.key].public_subnets_cidr_blocks
  # Web-Module does not contain SSH by default
  ingress_rules = [ "ssh-tcp" ]
  # add the SSH-Host networks
  ingress_cidr_blocks = concat(module.vpc[each.key].public_subnets_cidr_blocks, var.ssh_access_permit)
}

resource "random_string" "lb_id" {
  length  = 4
  special = false
}

# Security for the Load-Balancer
module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "3.12.0"

  for_each = var.project

  name = "load-balancer-sg-${each.key}-${each.value.environment}"

  description = "Security group for load balancer with ports open within VPC"
  vpc_id      = module.vpc[each.key].vpc_id

  # default only SSH, now add HTTPS
  ingress_rules = [ "https-443-tcp", "http-80-tcp" ]
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

  number_of_instances = length(module.ec2_instances[each.key].instance_ids)
  instances           = module.ec2_instances[each.key].instance_ids

  # forward traffic from 443 to 80
  listener = [
  {
    instance_port     = "8080"
    instance_protocol = "HTTP"
    lb_port           = "443"
    lb_protocol       = "HTTPS"
    ssl_certificate_id = var.ssl_cert
  },
  {
    instance_port     = "8080"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  },
  # I've added this, to see if I can get to instances via LB
  {
    instance_port     = "22"
    instance_protocol = "TCP"
    lb_port           = "22"
    lb_protocol       = "TCP"
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
