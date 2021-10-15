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

### Build Standard vSwitches ###

resource "vsphere_host_virtual_switch" "vswitch" {
  for_each      = var.cluster_hosts

  name              = var.vcenter_std_switch_name
  host_system_id    = data.vsphere_host.hosts[each.value["name"]].id
  network_adapters  = []
  active_nics       = []
  standby_nics      = []
}
