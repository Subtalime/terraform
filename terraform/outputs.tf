output "skytest_public_address2" {
  value       = aws_instance.skytest.public_ip
  description = "The public address of skytest host"
}
output "skytest_private_address" {
  value       = aws_instance.skytest.private_ip
  description = "The private address of skytest host"
}

output "skytest_website_address" {
  value       = "https://${var.route_53}.${var.domain_name}:${var.http_listener}"
  description = "The public DNS of skytest website"
}

