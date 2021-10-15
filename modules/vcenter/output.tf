# output "portgroups" {
#   value = vsphere_distributed_port_group.dpg
# }

output "hosts" {
  value = data.vsphere_host.hosts
}

output "merged" {
  value = local.merged
}
