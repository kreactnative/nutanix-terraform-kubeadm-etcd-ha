resource "docker_image" "etcd" {
  name = "harbor.socket9.com/etcd-cluster-gen/v1"
}

resource "docker_container" "etcd-gen" {
  depends_on = [
    module.etcd_domain
  ]
  image      = docker_image.etcd.image_id
  name       = "etcd-generate"
  privileged = true
  tty        = true
  rm         = true
  attach     = false
  env        = ["ETCD1_IP=${module.etcd_domain[0].address}", "ETCD2_IP=${module.etcd_domain[1].address}", "ETCD3_IP=${module.etcd_domain[2].address}"]
  volumes {
    container_path = "/app/certificate"
    host_path      = "${abspath(path.module)}/output"
  }
}

resource "null_resource" "etcd-config" {
  depends_on = [docker_container.etcd-gen]
  count      = length(module.etcd_domain)
  provisioner "file" {
    source      = "output/ca.pem"
    destination = "/home/${var.user}/ca.pem"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.etcd_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "output/etcd.pem"
    destination = "/home/${var.user}/etcd.pem"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.etcd_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "output/etcd-key.pem"
    destination = "/home/${var.user}/etcd-key.pem"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.etcd_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "output/${module.etcd_domain[count.index].name}.service"
    destination = "/home/${var.user}/etcd.service"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.etcd_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    connection {
      host        = module.etcd_domain[count.index].address
      user        = var.user
      private_key = file("~/.ssh/id_rsa")
    }
    script = "${path.root}/scripts/etcd.sh"
  }
}
