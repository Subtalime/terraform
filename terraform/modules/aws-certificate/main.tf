
# create AWS resource of that certificate
resource "aws_acm_certificate" "this" {
  private_key      = var.private_key_pem
  certificate_body = var.cert_pem
}


