# Amazon image of Centos
variable "ami_image" {
    description = "Centos AMI image with SSH Access as user centos"
#    default = "ami-05fd99a3530dfd34b"
    default = "ami-0e80a462ede03e653"
    type = string
}

variable "ssh_instance_user" {
    description = "The user to login via SSH to run Ansible"
    default = "ec2-user"
    type = string
}

variable "domain_name" {
    description = "The domain being used to route traffic"
    default = "ts-aws.net"
    type = string
}

variable "ssl_cert" {
    description = "ARN to the SSL-Certificate"
    default = "arn:aws:acm:eu-west-2:620672819820:certificate/b8c303af-d848-4e4d-8c7b-93086b7fd50a"
    type = string
}

variable "ssh_access_permit" {
    description = "Allow SSH access from these networks"
    default = ["86.25.180.0/24"]
    type = list(string)
}

variable "public_key_path" {
    description = "File-Path to the public key"
    default = "~/.ssh/keypair.pub"
    type = string
}

variable "private_key_path" {
    description = "File-Path to the private key"
    default = "~/.ssh/keypair.pem"
    type = string
}

variable "aws_region" {
    description = "Region where the AWS infrastructure is created"
    default = "eu-west-2"
    type = string
}

variable "cidr_vpc" {
    description = "CIDR for the VPC"
    default = "10.0.0.0/16"
}

variable public_subnet_cidr_blocks {
  description = "Available cidr blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
    "10.0.9.0/24",
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24",
    "10.0.14.0/24",
    "10.0.15.0/24",
    "10.0.16.0/24"
  ]
}

variable private_subnet_cidr_blocks {
  description = "Available cidr blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
    "10.0.109.0/24",
    "10.0.110.0/24",
    "10.0.111.0/24",
    "10.0.112.0/24",
    "10.0.113.0/24",
    "10.0.114.0/24",
    "10.0.115.0/24",
    "10.0.116.0/24"
  ]
}

variable project {
  description = "Map of project environments to configure."
  type        = map
  default     = {
    development = {
      public_subnets_per_vpc  = 1,
      private_subnets_per_vpc = 1,
      instances_per_subnet    = 2,
      instance_type           = "t2.nano",
      environment             = "dev",
      dns_name		      = "www2",
      dns_record_type         = "CNAME"
    },
    production = {
      public_subnets_per_vpc  = 1,
      private_subnets_per_vpc = 2,
      instances_per_subnet    = 1,
      instance_type           = "t2.nano",
      environment             = "prod",
      dns_name		      = "www",
      dns_record_type         = "CNAME"
    }
  }
}
