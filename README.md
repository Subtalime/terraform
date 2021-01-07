# Home Assignment to design and deploy a Production ready Web-Service in AWS

## Prerequisites
- install Ansible binaries for provisioning
- install Terraform for infrastructure deployment
- create AWS account and create an IAM Administrator user
- install AWS client and register the credentials for Administrative user
- register a Domain on AWS (because we are using SSL Web-Server)
- generate SSL certificate on AWS
- create a SSH Key to use for communication with the instances

## Configuration
All configurable values are stored in terraform/variables.tf. Make sure you check these before attempting to deploy.

## Execution
change in to the terraform folder and execute "apply"

## Caveats encountered
Name-Server records are not updated locally
to be able to use the URL, I needed to update the Nameserver to AWS, by issuing
systemd-resolve --set-dns=205.251.196.133 --interface=enp3s0
I was then able to call the Web-Page provided by "outputs.tf"
once finished, I reset it back to my Router DNS
systemd-resolve --set-dns=192.168.128.1 --interface=enp3s0
