variable instance_count {
  description = "Number of EC2 instances to deploy"
  type        = number
  default     = 1
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

variable private_key_path {
  description = "Path to the Private SSH-Key"
  type        = string
}

variable "ssh_user" {
    description = "User to access the AMI using the SSH-Key"
    type = string
}

variable "ssh_key_name" {
    description = "Resource to aws_key_pair"
    type = string
}
