variable "user" {
  description = "user for ssh"
  type        = string
  default     = "almalinux"
}
variable "ssh_key" {
  type    = string
}
variable "memory" {
  description = "Amount of memory needed"
  type        = string
}

variable "vcpus" {
  description = "Number of vcpus"
  type        = number
}

variable "sockets" {
  description = "Number of sockets"
  type        = number
}
variable "prefix_node_name" {
  description = "Target node name in proxmox"
  type        = string
}
variable "VM_COUNT" {
  description = "Number of masters to create (Should be an odd number)"
  type        = number
}
variable "nutanix_cluster_name" {
  type = string
}
variable "nutanix_subnet_name" {
  type = string
}