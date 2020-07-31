data "vsphere_datastore" "datastore" {
  name          = "${var.datastore}"
  datacenter_id = "${var.datacenter_id}"
}

data "vsphere_network" "network" {
  name          = "${var.network}"
  datacenter_id = "${var.datacenter_id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.template}"
  datacenter_id = "${var.datacenter_id}"
}

resource "vsphere_virtual_machine" "vm" {
  count            = var.instance_count

  name             = "${var.name}-${count.index}"
  resource_pool_id = var.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.cpu
  memory           = var.memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  folder           = var.folder
  enable_disk_uuid = "true"
/*
  wait_for_guest_net_timeout  = "0"
  wait_for_guest_net_routable = "false"
*/
  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label            = "disk0"
    size             = var.disk0
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  disk {
    label            = "disk1"
    size             = var.disk1
    unit_number      = 1
    thin_provisioned = data.vsphere_virtual_machine.template.disks.1.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  extra_config = {
    "guestinfo.userdata"          = "${var.userdata}"
    "guestinfo.userdata.encoding" = "gzip+base64"
    "guestinfo.metadata"          = <<-EOT
    {
        "local-hostname": "${var.name}-${count.index}.${var.cluster_domain}",
        "instance-id": "${var.name}-${count.index}.${var.cluster_domain}",
        "network": {
            "version": 2,
            "ethernets": {
                "ens192": {
                    "addresses": [
                    "${var.ip_addresses[count.index]}/${var.netmask}"
                    ],
                    "gateway4": "${var.gateway}",
                    "nameservers": {
                    "search": [
                        "${var.cluster_domain}"
                    ],
                    "addresses": [
                        "${var.dns}"
                    ]
                    }
                }
            }
        }
    }
    EOT
  }
}

resource "null_resource" "vm" {
  depends_on = [vsphere_virtual_machine.vm]

  triggers = {
    public_ip = element(vsphere_virtual_machine.vm.*.default_ip_address,0)
  }

  count = element(vsphere_virtual_machine.vm.*.name,0) == "bastion-0" ? 1 : 0

  provisioner "file" {
    source      = "${path.cwd}/inventory/ansible-hosts"
    destination = "~/hosts"
  }

  connection {
    host = element(vsphere_virtual_machine.vm.*.default_ip_address,0)
    type = "ssh"
    user = "cloud-user"
  }
}

