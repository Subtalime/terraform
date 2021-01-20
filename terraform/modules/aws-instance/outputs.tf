output instance_id {
  description = "IDs of EC2 instances"
  value       = aws_instance.app.*.id
}

output public_ip {
  description = "Public IPs of EC2 instances"
  value       = aws_instance.app.*.public_ip
}

output public_dns {
  description = "Public DNSs of EC2 instances"
  value       = aws_instance.app.*.public_dns
}
