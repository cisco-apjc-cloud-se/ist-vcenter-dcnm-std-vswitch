terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "mel-ciscolabs-com"
    workspaces {
      name = "ist-vcenter-dcnm-std-vswitch"
    }
  }
}
### Nested Modules ###

## DCNM Networking Module
module "dcnm" {
  source = "./modules/dcnm"

  dcnm_user             = var.dcnm_user
  dcnm_password         = var.dcnm_password
  dcnm_url              = var.dcnm_url
  dcnm_fabric           = var.dcnm_fabric
  dcnm_vrf              = var.dcnm_vrf
  cluster_interfaces    = var.cluster_interfaces
  cluster_networks      = var.cluster_networks
  vpc_interfaces        = var.vpc_interfaces
}

## VMware vCenter Module
module "vcenter" {
  source = "./modules/vcenter"

  vcenter_user            = var.vcenter_user
  vcenter_password        = var.vcenter_password
  vcenter_server          = var.vcenter_server
  vcenter_dc              = var.vcenter_dc
  vcenter_std_switch_name = var.vcenter_std_switch_name
  dcnm_networks           = module.dcnm.networks
  cluster_hosts           = var.cluster_hosts
}
