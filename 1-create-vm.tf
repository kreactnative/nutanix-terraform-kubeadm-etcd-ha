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
    command     = "mkdir -p output && rm -f nginx.conf cluster.yaml join-master.sh join-worker.sh helm-cni-lb.sh cloudinit.yaml istio.sh metal-ip.yaml"
    working_dir = path.root
  }
}

resource "local_file" "cloudinit" {
  content = templatefile("templates/cloudinit.tmpl",
    {
      user    = var.user,
      ssh_key = var.ssh_key
    }
  )
  filename = "cloudinit.yaml"
}

module "master_domain" {
  depends_on           = [local_file.cloudinit]
  source               = "./modules/domain"
  VM_COUNT             = var.MASTER_COUNT
  prefix_node_name     = "master"
  memory               = var.master_config.memory
  vcpus                = var.master_config.vcpus
  sockets              = var.master_config.sockets
  user                 = var.user
  cloudinit_data       = filebase64("${path.root}/cloudinit.yaml")
  nutanix_cluster_name = var.nutanix_cluster_name
  nutanix_subnet_name  = var.nutanix_subnet_name
}

module "worker_domain" {
  depends_on           = [local_file.cloudinit]
  source               = "./modules/domain"
  VM_COUNT             = var.WORKER_COUNT
  prefix_node_name     = "worker"
  memory               = var.worker_config.memory
  vcpus                = var.worker_config.vcpus
  sockets              = var.worker_config.sockets
  user                 = var.user
  cloudinit_data       = filebase64("${path.root}/cloudinit.yaml")
  nutanix_cluster_name = var.nutanix_cluster_name
  nutanix_subnet_name  = var.nutanix_subnet_name
}

module "etcd_domain" {
  depends_on           = [local_file.cloudinit]
  source               = "./modules/domain"
  VM_COUNT             = var.ETCD_COUNT
  prefix_node_name     = "etcd"
  memory               = var.etcd_config.memory
  vcpus                = var.etcd_config.vcpus
  sockets              = var.etcd_config.sockets
  user                 = var.user
  cloudinit_data       = filebase64("${path.root}/cloudinit.yaml")
  nutanix_cluster_name = var.nutanix_cluster_name
  nutanix_subnet_name  = var.nutanix_subnet_name
}

module "elb_domain" {
  depends_on           = [local_file.cloudinit]
  source               = "./modules/domain"
  VM_COUNT             = var.ELB_COUNT
  prefix_node_name     = "elb"
  memory               = var.elb_config.memory
  vcpus                = var.elb_config.vcpus
  sockets              = var.elb_config.sockets
  user                 = var.user
  cloudinit_data       = filebase64("${path.root}/cloudinit.yaml")
  nutanix_cluster_name = var.nutanix_cluster_name
  nutanix_subnet_name  = var.nutanix_subnet_name
}
