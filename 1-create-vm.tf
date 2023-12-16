terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
    nutanix = {
      source  = "nutanix/nutanix"
      version = "1.2.0"
    }
  }
}

provider "nutanix" {
  username     = var.nutanix_user
  password     = var.nutanix_password
  endpoint     = var.nutanix_endpoint
  insecure     = true
  wait_timeout = 60
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    command     = "mkdir -p output && rm -f nginx.conf cluster.yaml join-master.sh join-worker.sh helm-cni-lb.sh"
    working_dir = path.root
  }
}

resource "nutanix_image" "image" {
  name        = "Alma Linux"
  description = "Alma Linux"
  source_uri  = "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.3-20231113.x86_64.qcow2"
}

module "master_domain" {
  source           = "./modules/domain"
  VM_COUNT         = var.MASTER_COUNT
  prefix_node_name = "master"
  memory           = var.master_config.memory
  vcpus            = var.master_config.vcpus
  sockets          = var.master_config.sockets
  ssh_key          = var.ssh_key
  user             = var.user
}

module "worker_domain" {
  source           = "./modules/domain"
  VM_COUNT         = var.WORKER_COUNT
  prefix_node_name = "worker"
  memory           = var.worker_config.memory
  vcpus            = var.worker_config.vcpus
  sockets          = var.worker_config.sockets
  ssh_key          = var.ssh_key
  user             = var.user
}

module "etcd_domain" {
  source           = "./modules/domain"
  VM_COUNT         = var.ETCD_COUNT
  prefix_node_name = "etcd"
  memory           = var.etcd_config.memory
  vcpus            = var.etcd_config.vcpus
  sockets          = var.etcd_config.sockets
  ssh_key          = var.ssh_key
  user             = var.user
}

module "elb_domain" {
  source           = "./modules/domain"
  VM_COUNT         = var.ELB_COUNT
  prefix_node_name = "elb"
  memory           = var.elb_config.memory
  vcpus            = var.elb_config.vcpus
  sockets          = var.elb_config.sockets
  ssh_key          = var.ssh_key
  user             = var.user
}
