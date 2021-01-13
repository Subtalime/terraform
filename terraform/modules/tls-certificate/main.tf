

# make it a self signed one for short duration
resource "tls_self_signed_cert" "this" {
    key_algorithm   = "RSA"

    private_key_pem = var.private_key_pem

    subject {
	common_name  = var.dns_zone
        organization = var.organization
    }

    validity_period_hours = var.validity_hours

    allowed_uses = [
	"key_encipherment",
        "digital_signature",
	"server_auth",
    ]
}


