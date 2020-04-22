variable "ocp_version" {
  type        = string
  description = "OCP version"
}

variable "ocp_pkg_version" {
  type        = string
  description = "OCP package version"
}

variable "sdn_type" {
  type        = string
  description = "SDN type"
}

variable "reguser" {
  type        = string
  description = "RH registry user"
}

variable "regpass" {
  type        = string
  description = "RH registry password"
}

variable "rhak" {
  type        = string
  description = "RH activation key"
}

variable "rhorg" {
  type        = string
  description = "RH organization"
}

variable "ssh_key" {
  type        = string
  description = "SSH public key"
}

variable "cloudprovider" {
  type        = string
  description = "Cloud provider type"
}

variable "subdomain_prefix" {
  type        = string
  description = "Subdomain prefix"
}

variable "api_prefix" {
  type        = string
  description = "API prefix"
}

variable "cluster_id" {
  type        = string
  description = "This cluster id must be of max length 27 and must have only alphanumeric or hyphen characters."
}

variable "base_domain" {
  type        = string
  description = "The base DNS zone to add the sub zone to."
}

variable "machine_nm" {
  type        = string
  description = "Machine Netmask"
}

variable "machine_gw" {
  type        = string
  description = "Machine Gateway"
}

variable "machine_dns" {
  type        = string
  description = "Machine DNS"
}

variable "bastion_count" {
  description = "Bastion count"
}

variable "bastion_prefix" {
  type        = string
  description = "Bastion prefix"
}

variable "bastion_ip" {
  type        = string
  description = "Bastion IP"
}

variable "master_count" {
  description = "Master count"
}

variable "master_prefix" {
  type        = string
  description = "Master prefix"
}

variable "master_ips" {
  type        = list
  description = "Master IPs"
}

variable "worker_count" {
  description = "Worker count"
}

variable "worker_prefix" {
  type        = string
  description = "Worker prefix"
}

variable "worker_ips" {
  type        = list
  description = "Worker IPs"
}

variable "infra_count" {
  description = "Infra count"
}

variable "infra_prefix" {
  type        = string
  description = "Infra prefix"
}

variable "infra_ips" {
  type        = list
  description = "Infra IPs"
}

variable "cacertexpiry" {
  description = "CA Certificate expiration (in days)"
}

variable "certexpiry" {
  description = "Certificate expiration (in days)"
}

variable "use_customcerts" {
  description = "Use custom certificates"
}

variable "mastercert" {
  description = "Custom master certificate"
}

variable "routercert" {
  description = "Custom router certificate"
}

variable "install_metrics" {
  description = "Install metrics"
}

variable "install_monitoring" {
  description = "Install monitoring"
}

variable "install_logging" {
  description = "Install logging"
}

variable "use_pv_registry" {
  description = "Use persistent volume for registry storage"
}

variable "vsphere_server" {
  type        = string
  description = "This is the vSphere server for the environment."
}

variable "vsphere_user" {
  type        = string
  description = "vSphere server user for the environment."
}

variable "vsphere_password" {
  type        = string
  description = "vSphere server password for the environment."
}

variable "vsphere_datacenter" {
  type        = string
  description = "This is the name of the vSphere data center."
}

variable "vsphere_cluster" {
  type        = string
  description = "This is the name of the vSphere cluster."
}

variable "vsphere_datastore" {
  type        = string
  description = "This is the name of the vSphere data store."
}

variable "vm_template" {
  type        = string
  description = "This is the name of the VM template to clone."
}

variable "vm_network" {
  type        = string
  description = "This is the name of the publicly accessible network for cluster ingress and access."
}

locals {
  cluster_domain        = "${var.cluster_id}.${var.base_domain}"
  public_subdomain      = "${var.subdomain_prefix}.${local.cluster_domain}"
  public_api_hostname   = "${var.api_prefix}.${local.cluster_domain}"
  api_hostname          = "${var.api_prefix}-int.${local.cluster_domain}"
}

