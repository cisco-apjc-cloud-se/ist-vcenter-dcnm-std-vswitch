### DCNM Variables

variable "dcnm_user" {
  type = string
}

variable "dcnm_password" {
  type = string
}

variable "dcnm_url" {
  type = string
}

variable "dcnm_fabric" {
  type = string
}

variable "dcnm_vrf" {
  type = string
}

variable "vpc_interfaces" {
  type = map(object({
    name = string
    vpc_id = number
    switch1 = object({
      name = string
      ports = list(string)
      })
    switch2 = object({
      name = string
      ports = list(string)
      })
  }))
}

### vCenter Variables

variable "vcenter_user" {
  type = string
}

variable "vcenter_password" {
  type = string
}

variable "vcenter_server" {
  type = string
}

variable "vcenter_dc" {
  type = string
}

variable "vcenter_std_switch_name" {
  type = string
}

### Common Variables

variable "cluster_hosts" {
  type = map(object({
    name = string
    ip_addr = string
  }))
}

variable "cluster_interfaces" {
  type = map(object({
    name = string
    attach = bool
    switch_ports = list(string)
  }))
}

variable "cluster_networks" {
  type = map(object({
    name = string
    description = string
    ip_subnet = string
    vni_id = number
    vlan_id = number
    deploy = bool
  }))
}
