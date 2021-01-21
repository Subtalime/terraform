resource "aws_instance" "app" {
    count                  = var.instance_count
    ami                    = var.ami_image
    instance_type          = var.instance_type
    key_name               = var.ssh_key_name
    subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
    vpc_security_group_ids = var.security_group_ids

    associate_public_ip_address = var.assign_public_ip
    monitoring			= var.monitoring

    tags = {
        Terraform   = "true"
        Project     = var.project_name
        Environment = var.environment
    }


}

