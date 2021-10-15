output "hosts" {
  value = data.vsphere_host.hosts
}

output "merged" {
  value = local.merged
}
