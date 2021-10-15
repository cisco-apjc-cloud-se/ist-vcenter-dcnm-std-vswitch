output "portgroups" {
  value = vsphere_host_port_group.pg
}

output "hosts" {
  value = data.vsphere_host.hosts
}

output "merged" {
  value = local.merged
}
