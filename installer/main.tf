provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

module "folder" {
  source = "./folder"

  path          = var.cluster_id
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

module "resource_pool" {
  source = "./resource_pool"

  name            = "${var.cluster_id}"
  datacenter_id   = "${data.vsphere_datacenter.dc.id}"
  vsphere_cluster = "${var.vsphere_cluster}"
}

module "bastion" {
  source = "./machine"

  name             = "${var.bastion_prefix}"
  instance_count   = var.bastion_count
  resource_pool_id = "${module.resource_pool.pool_id}"
  datastore        = "${var.vsphere_datastore}"
  folder           = "${module.folder.path}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${local.cluster_domain}"
  ip_addresses     = "${compact(list(var.bastion_ip))}"
  netmask          = "${var.machine_nm}"
  gateway          = "${var.machine_gw}"
  dns              = "${var.machine_dns}"
  disk0            = "${var.bastion_disk0}"
  disk1            = "${var.bastion_disk1}"
  memory           = "${var.bastion_mem}"
  cpu              = "${var.bastion_cpu}"
  userdata         = "${data.template_cloudinit_config.sysprep-bastion.rendered}"
}

module "master" {
  source = "./machine"

  name             = "${var.master_prefix}"
  instance_count   = var.master_count
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${local.cluster_domain}"
  ip_addresses     = "${var.master_ips}"
  netmask          = "${var.machine_nm}"
  gateway          = "${var.machine_gw}"
  dns              = "${var.machine_dns}"
  disk0            = "${var.master_disk0}"
  disk1            = "${var.master_disk1}"
  memory           = "${var.master_mem}"
  cpu              = "${var.master_cpu}"
  userdata         = "${data.template_cloudinit_config.sysprep-openshift.rendered}"
}

module "worker" {
  source = "./machine"

  name             = "${var.worker_prefix}"
  instance_count   = var.worker_count
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${local.cluster_domain}"
  ip_addresses     = "${var.worker_ips}"
  netmask          = "${var.machine_nm}"
  gateway          = "${var.machine_gw}"
  dns              = "${var.machine_dns}"
  disk0            = "${var.worker_disk0}"
  disk1            = "${var.worker_disk1}"
  memory           = "${var.worker_mem}"
  cpu              = "${var.worker_cpu}"
  userdata         = "${data.template_cloudinit_config.sysprep-openshift.rendered}"
}

module "infra" {
  source = "./machine"

  name             = "${var.infra_prefix}"
  instance_count   = var.infra_count
  resource_pool_id = "${module.resource_pool.pool_id}"
  folder           = "${module.folder.path}"
  datastore        = "${var.vsphere_datastore}"
  network          = "${var.vm_network}"
  datacenter_id    = "${data.vsphere_datacenter.dc.id}"
  template         = "${var.vm_template}"
  cluster_domain   = "${local.cluster_domain}"
  ip_addresses     = "${var.infra_ips}"
  netmask          = "${var.machine_nm}"
  gateway          = "${var.machine_gw}"
  dns              = "${var.machine_dns}"
  disk0            = "${var.infra_disk0}"
  disk1            = "${var.infra_disk1}"
  memory           = "${var.infra_mem}"
  cpu              = "${var.infra_cpu}"
  userdata         = "${data.template_cloudinit_config.sysprep-openshift.rendered}"
}

