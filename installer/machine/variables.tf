variable "name" {
  type = string
}

variable "instance_count" {
  type = string
}

variable "resource_pool_id" {
  type = string
}

variable "folder" {
  type = string
}

variable "datastore" {
  type = string
}

variable "network" {
  type = string
}

variable "datacenter_id" {
  type = string
}

variable "template" {
  type = string
}

variable "cluster_domain" {
  type = string
}

variable "ip_addresses" {
  type = list
}

variable "netmask" {
  type = string
}

variable "gateway" {
  type = string
}

variable "dns" {
  type = string
}

variable "disk0" {
  type = string
}

variable "disk1" {
  type = string
}

variable "memory" {
  type = string
}

variable "cpu" {
  type = string
}

variable "userdata" {
  type = string
}
