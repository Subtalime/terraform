

variable private_key_pem {
    description = "Content of the PEM part of the certificate"
    type = string
}

variable dns_zone {
    description = "the Domain-Name that the certificate is associated to"
    type = string
}

variable organization {
    description = "Organzation description"
    type = string
}

variable validity_hours {
    description = "How long to the certificate is to be valid for (hours)"
    type = number
    default = 12
}
