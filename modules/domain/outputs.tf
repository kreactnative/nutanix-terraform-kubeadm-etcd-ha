output "address" {
  value       = nutanix_virtual_machine.vm[*].nic_list_status[0].ip_endpoint_list[0].ip
  description = "IP Address of the node"
}

output "name" {
  value       = nutanix_virtual_machine.vm[*].name
  description = "Name of the node"
}
