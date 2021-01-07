# set the region contained in variables.tf
provider "aws" {
    region = var.region
}


# EC2 instances
resource "aws_instance" "skytest" {
    ami = var.image
    instance_type = var.type
    key_name = aws_key_pair.ec2key.key_name
    subnet_id = aws_subnet.subnet_public_a.id
    vpc_security_group_ids = [ aws_security_group.sg_public.id ]

    tags = {
	Name = "skytest"
	Environment = var.environment_tag
    }

    # We run this to make sure server is initialized before we run the "local exec"
    provisioner "remote-exec" {
        connection {
          type        = "ssh"
          agent       = false
          host        = self.public_ip
          user        = "centos"
          private_key = file(var.private_key_path)
#          bastion_host        = self.public_ip
#          bastion_private_key = file(var.private_key_path)
        }
        inline = ["echo 'Server is ready for connection'"]
    }

    provisioner "local-exec" {
      command = <<EOT
          ansible-playbook \
         -i '${self.public_ip},' \
         -u centos \
            --private-key ${var.private_key_path} \
           ../ansible/frontend.yml
        EOT
    }

}


