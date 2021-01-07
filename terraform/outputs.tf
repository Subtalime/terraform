output "skytest_public_address2" {
  value       = aws_instance.skytest.public_ip
  description = "The public address of skytest host"
}
output "skytest_private_address" {
  value       = aws_instance.skytest.private_ip
  description = "The private address of skytest host"
}

#output "frontend_public_address" {
#  value       = aws_instance.frontend.public_ip
#  description = "The public address of frontend host"
#}
#output "frontend_private_address" {
#  value       = aws_instance.frontend.private_ip
#  description = "The private address of frontend host"
#}

#output "skytest_lb_dns" {
#  value       = aws_lb.skytest.dns_name
#  description = "The DNS name of the skytest Load Balancer"
#}

output "skytest_website_address" {
  value       = "http://www.ts-aws.net:${var.http_listener}"
  description = "The public DNS of skytest website"
}

