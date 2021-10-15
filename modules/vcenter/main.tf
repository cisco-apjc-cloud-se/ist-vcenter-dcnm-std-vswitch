terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      # version = "1.24.2"
    }
  }
}

### vSphere ESXi Provider ###
provider "vsphere" {
  user           = var.vcenter_user
  password       = var.vcenter_password
  vsphere_server = var.vcenter_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

### Existing Data Sources ###
data "vsphere_datacenter" "dc" {
  name          = var.vcenter_dc
}

data "vsphere_host" "hosts" {
  for_each      = var.cluster_hosts

  name          = each.value["name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

### Build Local Dictionary ###
locals {
  merged = flatten([
    for host_key, host in var.cluster_hosts : [
      for network_key, network in var.dcnm_networks : {
        network_name = network["name"]
        host_name  = host["name"]
      }
    ]
  ])
}

### Build Standard vSwitches ###
resource "vsphere_host_virtual_switch" "vswitch" {
  for_each      = var.cluster_hosts

  name              = var.vcenter_std_switch_name
  host_system_id    = data.vsphere_host.hosts[each.key].id
  network_adapters  = each.value["network_adapters"]
  active_nics       = each.value["active_nics"]
  standby_nics      = each.value["standby_nics"]
}


resource "vsphere_host_port_group" "pg" {
  for_each      = toset(local.merged)

  name                = each.value["network_name"]
  host_system_id      = data.vsphere_host.hosts[each.value["host_name"]].id
  virtual_switch_name = var.vcenter_std_switch_name

  depends_on = [vsphere_host_virtual_switch.vswitch]
}
