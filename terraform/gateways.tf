# Elastic IPs
resource "aws_eip" "nat_a" {
    vpc = true
}
resource "aws_eip" "nat_b" {
    vpc = true
}

# Network-Address-Translation Gateways
resource "aws_nat_gateway" "ngw_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.subnet_public_a.id

  tags = {
    Name = "nat-gw-a"
  }
}
resource "aws_nat_gateway" "ngw_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.subnet_public_b.id

  tags = {
    Name = "nat-gw-b"
  }
}
