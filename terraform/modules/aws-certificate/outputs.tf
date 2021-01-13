output "id" {
  description = "The ID of the certificate"
  value       = concat(aws_acm_certificate.this.*.id, [""])[0]
}

