output "skytest_a_public_address2" {
  value       = aws_instance.skytest_a.public_ip
  description = "The public address of skytest host"
}

output "skytest_b_public_address" {
  value       = aws_instance.skytest_b.public_ip
  description = "The public address of skytest host"
}

output "skytest_website_address" {
  value       = "https://${var.route_53}.${var.domain_name}"
  description = "The public DNS of skytest website"
}

