variable "region" {
    description = "Region where the AWS infrastructure is created"
    default = "eu-west-2"
    type = string
}

variable "availability_zone" {
    description = "Zone for the Subnets"
    default = "eu-west-2a"
    type = string
}

data "aws_availability_zones" "available" {
    state = "available"
}

variable "type" {
    description = "the EC2 instance type to be used"
    default = "t2.micro"
    type = string
}

# Amazon image of Centos
variable "image" {
    description = "Centos AMI image with SSH Access as user centos"
    default = "ami-05fd99a3530dfd34b"
    type = string
}

variable "cidr_vpc" {
    description = "CIDR for the VPC"
    default = "10.1.0.0/16"
}

variable "subnet_cidr_newbits" {
  description = "The newbits value as per cidrsubnet function docs"
  type        = string
  default     = 4
}

variable "environment_tag" {
    description = "tag to mark the environment"
    default = "skytest"
    type = string
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

variable "http_listener" {
    description = "the ingress port to the Web-Service"
    default = 443
    type = number
}

variable "domain_name" {
    description = "The domain being used to route traffic"
    default = "ts-aws.net"
    type = string
}

variable "route_53" {
    description = "The URI for the service"
    default = "www.ts-aws.net"
    type = string
}

variable "ssh_location" {
    description = "Allow SSH access from this network only"
    default = "86.25.180.0/24"
    type = string
}

variable "open_network" {
    description = "Allow access from this network"
    default = "0.0.0.0/0"
    type = string
}
