output "address" {
  value       = nutanix_virtual_machine.vm[*].nic_list_status[0].ip_endpoint_list[0]
  description = "IP Address of the nodes"
}

output "name" {
  value       = nutanix_virtual_machine.vm[*].name
  description = "Name of the nodes"
}
