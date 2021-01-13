output instance_ids {
  description = "IDs of EC2 instances"
  value       = aws_instance.app.*.id
}

output public_ips {
  description = "Public IPs of EC2 instances"
  value       = aws_instance.app.*.public_ip
}

output public_dns {
  description = "Public DNSs of EC2 instances"
  value       = aws_instance.app.*.public_dns
}
