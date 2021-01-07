# the VPC
resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_vpc
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
	Name = "main-vpc"
	Environment = var.environment_tag
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
	Name = "main-vpc-internet-gateway"
	Environment = var.environment_tag
    }
}

# Route Table
resource "aws_route_table" "rt_public" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = var.open_network
	gateway_id = aws_internet_gateway.igw.id
    }

  tags = {
	Name = "public-route-table"
	Environment = var.environment_tag
    }
}

resource "aws_route_table" "rt_private_a" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = var.open_network
	gateway_id = aws_nat_gateway.ngw_a.id
    }

  tags = {
	Name = "private-route-a"
	Environment = var.environment_tag
    }
}

resource "aws_route_table" "rt_private_b" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = var.open_network
	gateway_id = aws_nat_gateway.ngw_b.id
    }

  tags = {
	Name = "private-route-b"
	Environment = var.environment_tag
    }
}

# Subnet - Route Table associations
resource "aws_route_table_association" "rta_public_a" {
  subnet_id      = aws_subnet.subnet_public_a.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_public_b" {
  subnet_id      = aws_subnet.subnet_public_b.id
  route_table_id = aws_route_table.rt_public.id
}
resource "aws_route_table_association" "rta_private_a" {
  subnet_id      = aws_subnet.subnet_private_a.id
  route_table_id = aws_route_table.rt_private_a.id
}
resource "aws_route_table_association" "rta_private_b" {
  subnet_id      = aws_subnet.subnet_private_b.id
  route_table_id = aws_route_table.rt_private_b.id
}


# DNS configuration
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}
# create an A record with the resolver-name of the LB (perhaps should really be a CNAME)
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.route_53
  type    = "A"
  alias {
    name    = aws_elb.elb_frontend.dns_name
    zone_id = aws_elb.elb_frontend.zone_id
    evaluate_target_health = true
  }
}
