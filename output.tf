output "openshift_public_api_hostname" {
  value = local.public_api_hostname
}

output "openshift_subdomain" {
  value = local.public_subdomain
}

output "bastion_ip" {
  value = var.bastion_ip
}

