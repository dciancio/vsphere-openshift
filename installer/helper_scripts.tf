locals {
  ansible_version = var.ocp_version == "3.11" ? "2.6" : "2.4"
}

data "template_file" "init" {
  template = file("./helper_scripts/init.template")
  vars = {
    ssh_key         = var.ssh_key
  }
}

data "template_file" "sysprep-bastion" {
  template = file("./helper_scripts/sysprep-bastion.sh")
  vars = {
    rhak            = var.rhak
    rhorg           = var.rhorg
    ocp_version     = var.ocp_version
    ansible_version = local.ansible_version
    domain          = local.cluster_domain
  }
}

data "template_file" "sysprep-openshift" {
  template = file("./helper_scripts/sysprep-openshift.sh")
  vars = {
    rhak            = var.rhak
    rhorg           = var.rhorg
    ocp_version     = var.ocp_version
    ansible_version = local.ansible_version
    domain          = local.cluster_domain
  }
}

data "template_cloudinit_config" "sysprep-bastion" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.init.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.sysprep-bastion.rendered}"
  }
}

data "template_cloudinit_config" "sysprep-openshift" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.init.rendered}"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.sysprep-openshift.rendered}"
  }
}

