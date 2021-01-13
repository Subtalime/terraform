variable "create" {
  description = "Whether to create DNS records"
  type        = bool
  default     = true
}

variable "zone_id" {
  description = "ID of DNS zone"
  type        = string
}

variable "zone_name" {
  description = "Name of DNS zone"
  type        = string
}

variable "private_zone" {
  description = "Whether Route53 zone is private or public"
  type        = bool
  default     = false
}

variable "records" {
  description = "List of maps of DNS records"
  type        = any
  default     = []
}

variable "allow_overwrite" {
  description = "Whether to overwrite existing records"
  type	      = bool
  default     = true
}
