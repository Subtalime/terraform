# Store the SSH Key
resource "aws_key_pair" "ec2key" {
    key_name = "publicKey"
    public_key = file(var.public_key_path)
}

# Security access for services to certain networks
# From world
resource "aws_security_group" "sg_public" {
    name = "sg_public"
    description = "Allow Ping, SSH and HTTPS"
    vpc_id = aws_vpc.vpc.id

    ingress {
	description = "HTTPS"
	from_port = 443
	to_port = 443
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
	description = "HTTP"
	from_port = 8080
	to_port = 8080
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
	description = "SSH"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = [var.ssh_location]
    }
    ingress {
	description = "Ping"
	from_port = -1
	to_port = -1
	protocol = "icmp"
	cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
	from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
	Name = "public-sg"
	Environment = var.environment_tag
    }
}

# within the VPC
resource "aws_security_group" "sg_private" {
    name = "sg_private"
    description = "Allow Ping, SSH and HTTP (8080) in private networks"
    vpc_id = aws_vpc.vpc.id

    ingress {
	description = "HTTP"
	from_port = 8080
	to_port = 8080
	protocol = "tcp"
	cidr_blocks = [aws_vpc.vpc.cidr_block]
    }
    ingress {
	description = "SSH"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = [aws_vpc.vpc.cidr_block]
    }
    ingress {
	description = "Ping"
	from_port = -1
	to_port = -1
	protocol = "icmp"
	cidr_blocks = [aws_vpc.vpc.cidr_block]
    }
    egress {
	from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
	Name = "private-sg"
	Environment = var.environment_tag
    }
}


