# Intersight Service for Terraform Demo - Basic DCN & VMware Networking Automation using Standard vSwitches

[![published](https://static.production.devnetcloud.com/codeexchange/assets/images/devnet-published.svg)](https://developer.cisco.com/codeexchange/github/repo/cisco-apjc-cloud-se/ist-vcenter-dcnm-std-vswitch)

## Overview
This is a alternate version of the “Basic DCN & VMware Networking Automation” use case that focuses solely on DCNM and vCenter networking automation, specifically the automation of a DCNM-based VXLAN EVPN fabric connecting to a VMware ESXi cluster where using a Distributed Virutal Switch is not possible.  This may be due to licensing constraints as the DVS function is only available with the VMware Enterprise Plus level of ESXi licensing.

This example will create the following:
- A dedicated vPC interface for each host in the cluster
- A set of new L3 VXLAN networks on an existing VRF.  These new networks will be trunked to each of the new interfaces above.
- A new standard vSwitch for each host in the cluster.  This would be configured to use the physical NICs of the hosts connected to the vPC interfaces defined above.
- A new standard port-group for eaach of the L3 VXLAN networks defined above.

## Requirements
The Infrastructure-as-Code environment will require the following:
* GitHub Repository for Terraform plans, modules and variables as JSON files
* Terraform Cloud for Business account with a workspace associated to the GitHub repository above
* Cisco Intersight (SaaS) platform account with sufficient Advantage licensing
* An Intersight Assist appliance VM connected to the Intersight account above

This example will then use the following on-premise domain managers. These will need to be fully commissioned and a suitable user account provided for Terraform to use for provisioning.
* Cisco Data Center Network Manager (DCNM)
* VMware vCenter

## Assumptions
The DC Networking module makes the following assumptions:
* An existing Nexus 9000 switch based VXLAN fabric has already been deployed and that it is actively managed through a DCNM instance.
* The DCNM server is accessible by HTTPS from the Intersight Assist VM.
* An existing VRF is available to use for new L3 VXLAN networks.  Any dynamic routing/peering to external devices (including firewalls) have already be configured as necessary.
* Suitable IP subnets (at least /29) are available to be assigned to each new L3 network.
* Suitable VLAN IDs are available to be assigned to each new L3 network.
* The following variables are defined within the Terraform Workspace.  These variables should not be configured within the public GitHub repository files.
  * DCNM account username (dcnm_user)
  * DCNM account password (dcnm_password)
  *	DCNM URL (dcnm_url)

The vCenter module makes the following assumptions:
* A group of VMware host servers are configured as a single VMware server cluster within a logical VMware Data Center, managed from an existing vCenter instance.  
* The vCenter server is accessible by HTTPS from the Intersight Assist VM.
* VMware host servers have commissioned and are physically patched to trunked switch ports (or VPCs) on the VXLAN fabric access (leaf) switches.  Note:  The physical NICs (i.e. vmnicXX) for each host will need to be defined in the input variables.  This example does not explicitly associate the physical NIC to the new vSwitch as uplinks but this would be expected in an actual deployment.
* The following variables are defined within the Terraform Workspace.  These variables should not be configured within the public GitHub repository files.
  * vCenter account username (vcenter_user)
  * vCenter account password (vcenter_password)
  * vCenter server IP/FQDN (vcenter_server)


## Link to Github Repositories
https://github.com/cisco-apjc-cloud-se/ist-vcenter-dcnm-std-vswitch

## Steps to Deploy Use Case
1.	In GitHub, create a new, or clone the example GitHub repository(s)
2.	Customize the examples Terraform files & input variables as required
3.	In Intersight, configure a Terraform Cloud target with suitable user account and token
4.	In Intersight, configure a Terraform Agent target with suitable managed host URLs/IPs.  This list of managed hosts must include the IP addresses for the DCNM & vCenter server as well as access to common GitHub domains in order to download hosted Terraform providers.  This will create a Terraform Cloud Agent pool and register this to Terraform Cloud.
5.	In Terraform Cloud for Business, create a new Terraform Workspace and associate to the GitHub repository.
6.	In Terraform Cloud for Business, configure the workspace to the use the Terraform Agent pool configured from Intersight.
7.	In Terraform Cloud for Business, configure the necessary user account variables for the DCNM and vCenter servers.

## Workarounds ##

*October 2021*
In this example, both VLAN IDs and VXLAN IDs have been explicity set.  These are optional parameters and can be removed and left to DCNM to inject these dynamically from the fabrics' resource pools.  However if you chose to use DCNM to do this, Terraform MUST be configured to use a "parallelism" value of 1.  This ensures Terraform will only attempt to configure one resource at a time allowing DCNM to allocate IDs from the pool sequentially.  

Typically the parallelism would be set in the Terraform cloud workspace environment variables section using the variable name "TFE_PARALLELISM" and value of "1", however this variable is NOT used by Terraform Cloud Agents.  Instead the variables "TF_CLI_ARGS_plan" and "TF_CLI_ARGS_apply" must be used with a value of "-parallelism=1"


*October 2021* Due to an issue with the Terraform Provider (version 1.0.0) and DCNM API (11.5(3)) the "dcnm_network" resource will not deploy Layer 3 SVIs.  This is due to a defaul parameter not being correctly set in the API call.  Instead, the Network will be deployed as if the template has the "Layer 2 Only" checkbox set.

There are two workarouds for this
1. After deploying the network(s), edit the network from the DCNM GUI then immediately save.  This will set the correct default parameters and these networks can be re-deployed.
2. Instead of the using the "Default_Network_Universal" template, clone and modify it as below.  Make sure to set the correct template name in the terraform plan under the dcnm_network resource.   Please note that the tag value of 12345 must also be explicity set.

    Original Lines #119-#123
    ```
    if ($$isLayer2Only$$ != "true") {
      interface Vlan$$vlanId$$
       if ($$intfDescription$$ != "") {
        description $$intfDescription$$
       }
    ```
    Modified Lines #119-#125
    ```
    if ($$isLayer2Only$$ == "true"){
     }
    else {
    interface Vlan$$vlanId$$
     if ($$intfDescription$$ != "") {
      description $$intfDescription$$
     }
    ```

## Example Input Variables ###
```hcl
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
  host1 = {
    name              = "100.64.62.21"
    network_adapters  = []
    active_nics       = []
    standby_nics      = []
  },
  host2 = {
    name              = "100.64.62.22"
    network_adapters  = []
    active_nics       = []
    standby_nics      = []
  },
  host3 = {
    name              = "100.64.62.23"
    network_adapters  = []
    active_nics       = []
    standby_nics      = []
  },
  host4 = {
    name              = "100.64.62.24"
    network_adapters  = []
    active_nics       = []
    standby_nics      = []
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
```

## Execute Deployment
In Terraform Cloud for Business, queue a new plan to trigger the initial deployment.  Any future changes to pushed to the GitHub repository will automatically trigger a new plan deployment.

## Results
If successfully executed, the Terraform plan will result in the following configuration:

* New vPC Interfaces for each host in the cluster
  * vPC ID
  * Member ports per switch pair

* New Layer 3 VXLAN network(s) each with the following configuration:
  * Name
  * Anycast Gateway IPv4 Address/Mask
  * VXLAN VNI ID
  * VLAN ID
  * Trunked to each new vPC interface

* New Standard vSwitch "IST-STDVSW" creatd on each host in the cluster

* New Standard Port Groups for each VXLAN network defined above
  * Name
  * VLAN ID


## Expected Day 2 Changes
Changes to the variables defined in the input variable files will result in dynamic, stateful update to DCNM. For example,

* Adding a Network entry will create a new DCNM Network template instance and deploy this network to the associated switches, as well as trunk to the associated switch interfaces towards the ESXi hosts.
* Adding a Network entry will also create a matching standard port group on the specific VMware standard vSwitch for each host.
* Adding a new host to the VMware host cluster and distributed switch will ensure the hew host inherits the standard vSwitch and port group configuration.  Adding the new hosts' interfaces to the "cluster_interfaces" variable will ensure that all necessary VLANs are trunked to the new host.
