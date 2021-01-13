resource "aws_instance" "app" {
    count                  = var.instance_count
    ami                    = var.ami_image
    instance_type          = var.instance_type
    key_name               = var.ssh_key_name
    subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
    vpc_security_group_ids = var.security_group_ids

    # we need this to execute Ansible
    associate_public_ip_address = true

    tags = {
        Terraform   = "true"
        Project     = var.project_name
        Environment = var.environment
    }

    # We run this to make sure server is initialized before we run the "local exec"
    provisioner "remote-exec" {
        connection {
          type        = "ssh"
          agent       = false
          host        = self.public_ip
          user        = var.ssh_user
          private_key = file(var.private_key_path)
        }
        inline = ["echo 'Server is ready for connection'"]
    }

    provisioner "local-exec" {
      command = <<EOT
          ansible-playbook \
         -i '${self.public_ip},' \
         -u ${var.ssh_user} \
            --private-key ${var.private_key_path} \
           ../ansible/frontend.yml
        EOT
    }
}

