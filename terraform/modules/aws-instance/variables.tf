variable instance_count {
  description = "Number of EC2 instances to deploy"
  type        = number
  default     = 1
}

variable assign_public_ip {
  description = "Whether to get a Public-IP for this instance"
  type        = bool
  default     = false
}

variable monitoring {
    description = "enable detailed monitoring"
    type = bool
    default = true
}

variable instance_type {
  description = "Type of EC2 instance to use"
  type        = string
}

variable subnet_ids {
  description = "Subnet IDs for EC2 instances"
  type        = list(string)
}

variable security_group_ids {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable project_name {
  description = "Name of the project"
  type        = string
}

variable environment {
  description = "Name of the environment"
  type        = string
}

variable ami_image {
  description = "The AMI image to be used"
  type        = string
}

variable "ssh_key_name" {
    description = "Resource to aws_key_pair"
    type = string
}
