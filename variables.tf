variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHQPduvBBBOALoMK0SMb9oXkORwB4G6pD1ZoNyASTfWmQ0mP/GIUnMoi5RdxOgoHEP9fg+ktqw66Zeamfxa22GYltZf9ayf9rSnENbQeGgbNTFShjYE6q675ryPyx/kWf+yWWdPV4KBg1rjqdWyxcd12f2BPi9cXU1q9W03b2VMrNhuC9lzPD3Fitto/yrlJQ7iVbVn/TvAIJxOAQ/v5wa/QA2uxZ2e95khMfy8t26u2KA5KcHTZ4b/OPq2pjGTeAebfKiB7Ou07fC9NHYp7vj4TZ0ISnyt9ePk1a+SaLeP7eA8ZqEnqIurLrMVhmGNSJ1OT7vGIWpCbms1QJPtWZv root@pve"
}
variable "user" {
  description = "user for ssh"
  type        = string
  default     = "almalinux"
}
# Cluster config
variable "MASTER_COUNT" {
  description = "Number of masters to create (Should be an odd number)"
  type        = number
}

variable "WORKER_COUNT" {
  description = "Number of workers to create"
  type        = number
}

variable "ETCD_COUNT" {
  description = "Number of etct to create"
  type        = number
}

variable "ELB_COUNT" {
  description = "Number of etct to create"
  type        = number
  default     = 1
}

variable "master_config" {
  description = "Kubernetes master config"
  type = object({
    memory  = string
    vcpus   = number
    sockets = number
  })
}

variable "worker_config" {
  description = "Kubernetes worker config"
  type = object({
    memory  = string
    vcpus   = number
    sockets = number
  })
}

variable "etcd_config" {
  description = "Kubernetes ETCD config"
  type = object({
    memory  = string
    vcpus   = number
    sockets = number
  })
}
variable "elb_config" {
  description = "Kubernetes ELB config"
  type = object({
    memory  = string
    vcpus   = number
    sockets = number
  })
}
