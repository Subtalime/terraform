# Subnet
resource "aws_subnet" "subnet_public_a" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.cidr_vpc, var.subnet_cidr_newbits, 0)
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
        Name = "public-subnet-a"
        Environment = var.environment_tag
    }
}
resource "aws_subnet" "subnet_public_b" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.cidr_vpc, var.subnet_cidr_newbits, 1)
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
        Name = "public-subnet-b"
        Environment = var.environment_tag
    }
}

resource "aws_subnet" "subnet_private_a" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.cidr_vpc, var.subnet_cidr_newbits, 2)
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
        Name = "private-subnet-a"
        Environment = var.environment_tag
    }
}
resource "aws_subnet" "subnet_private_b" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = cidrsubnet(var.cidr_vpc, var.subnet_cidr_newbits, 3)
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[1]
    tags = {
        Name = "private-subnet-b"
        Environment = var.environment_tag
    }
}

