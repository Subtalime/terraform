output public_dns_names {
  description = "Public DNS names of the load balancers for each project"
  value       = { for p in sort(keys(var.project)) : p => module.elb_http[p].this_elb_dns_name }
}

output vpc_arns {
  description = "ARNs of the vpcs for each project"
  value       = { for p in sort(keys(var.project)) : p => module.vpc[p].vpc_arn }
}

output instance_ids {
  description = "IDs of EC2 instances"
  value       = { for p in sort(keys(var.project)) : p => module.ec2_instances[p].instance_id }
}

output public_bastion_ips {
  description = "Public IPs of the Bastion-Hosts for each project"
  value       = { for p in sort(keys(var.project)) : p => module.bastion_instances[p].public_ip }
}

output public_bastion_dns {
  description = "Public DNSs of the Bastion-Hosts for each project"
  value       = { for p in sort(keys(var.project)) : p => module.bastion_instances[p].public_dns }
}

output public_instance_ips {
  description = "Public IPs of the instance for each project"
  value       = { for p in sort(keys(var.project)) : p => module.ec2_instances[p].public_ip }
}

output private_instance_dns {
  description = "Public DNSs of the instance for each project"
  value       = { for p in sort(keys(var.project)) : p => module.ec2_instances[p].private_dns }
}

variable "inventory_path" {
    default = "../ansible/inventory/inventory.ini"
}

resource "local_file" "config" {
    content = templatefile("./ansible_config.tmpl", {
	private_key 	= var.private_key_path,
	ssh_user	= var.ssh_instance_user,
	inventory_path  = var.inventory_path
    })
    filename = "../ansible/ansible.cfg"
}

resource "local_file" "inventory" {
    content = templatefile("./ansible_inventory.tmpl", {
	elb 		= module.elb_http,
	http 		= module.ec2_instances,
	bastion 	= module.bastion_instances,
	ssh_user 	= var.ssh_instance_user
    })
    filename = var.inventory_path
}

