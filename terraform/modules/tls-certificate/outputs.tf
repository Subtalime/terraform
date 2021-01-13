output "cert_pem" {
  description = "The PEM of the certificate"
  value       = concat(tls_self_signed_cert.this.*.cert_pem, [""])[0]
}

