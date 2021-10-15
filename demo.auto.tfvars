
### DCNM DETAILS ###
dcnm_fabric             = "DC3"
dcnm_vrf                = "GUI-VRF-1"

### Build vPC interface per ESXi host ###
vpc_interfaces = {
  vpc21 = {
    name = "vPC21"
    vpc_id = 21
    switch1 = {
      name = "DC3-LEAF-1"
      ports = ["Eth1/21"]
      }
    switch2 = {
      name = "DC3-LEAF-2"
      ports = ["Eth1/21"]
      }
  },
  vpc22 = {
    name = "vPC22"
    vpc_id = 22
    switch1 = {
      name = "DC3-LEAF-1"
      ports = ["Eth1/22"]
      }
    switch2 = {
      name = "DC3-LEAF-2"
      ports = ["Eth1/22"]
      }
  }
  vpc23 = {
    name = "vPC23"
    vpc_id = 23
    switch1 = {
      name = "DC3-LEAF-1"
      ports = ["Eth1/23"]
      }
    switch2 = {
      name = "DC3-LEAF-2"
      ports = ["Eth1/23"]
      }
  }
  vpc24 = {
    name = "vPC24"
    vpc_id = 24
    switch1 = {
      name = "DC3-LEAF-1"
      ports = ["Eth1/24"]
      }
    switch2 = {
      name = "DC3-LEAF-2"
      ports = ["Eth1/24"]
      }
  }
}

### VMWARE DETAILS ###
vcenter_dc              = "CPOC-HX"
vcenter_std_switch_name = "IST-STDVSW"

### CLUSTER DETAILS ###

### Which hosts make up the cluster ###
cluster_hosts = {
  100.64.62.21 = {
    name = "100.64.62.21"
    ip_addr = "100.64.62.21"
  },
  100.64.62.22 = {
    name = "100.64.62.22"
    ip_addr = "100.64.62.22"
  },
  100.64.62.23 = {
    name = "100.64.62.23"
    ip_addr = "100.64.62.23"
  },
  100.64.62.24 = {
    name = "100.64.62.24"
    ip_addr = "100.64.62.24"
  }
}

### Which switch interfaces are connected to the hosts' vswitches ###
cluster_interfaces      = {
  DC3-LEAF-1 = {
    name    = "DC3-LEAF-1"
    attach  = true
    switch_ports = [
      "Port-channel21",
      "Port-channel22",
      "Port-channel23",
      "Port-channel24"
    ]
  },
  DC3-LEAF-2 = {
    name    = "DC3-LEAF-2"
    attach  = true
    switch_ports = [
      "Port-channel21",
      "Port-channel22",
      "Port-channel23",
      "Port-channel24"
    ]
  }
}

### Which networks we want to configure and to trunk to the vswitches ###
cluster_networks = {
  IST-STDNET-1 = {
    name        = "IST-STDNET-1"
    description = "Terraform Standard vSwitch Network #1"
    ip_subnet   = "192.168.21.1/24"
    vni_id      = 33112
    vlan_id     = 3112
    deploy      = true
  },
  IST-STDNET-2 = {
    name        = "IST-STDNET-2"
    description = "Terraform Standard vSwitch Network #2"
    ip_subnet   = "192.168.22.1/24"
    vni_id      = 33113
    vlan_id     = 3113
    deploy      = true
  }
}
