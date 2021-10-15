output "networks" {
  value = module.dcnm.networks
  sensitive = false
}

output "hosts" {
  value = module.vcenter.hosts
  sensitive = false
}

output "merged" {
  value = module.vcenter.merged
  sensitive = false
}

output "portgroups" {
  value = module.vcenter.portgroups
  sensitive = false
}
