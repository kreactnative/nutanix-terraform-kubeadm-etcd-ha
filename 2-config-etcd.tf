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
  env        = ["ETCD1_IP=${module.etcd_domain.address[0]}", "ETCD2_IP=${module.etcd_domain.address[1]}", "ETCD3_IP=${module.etcd_domain.address[2]}"]
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
    destination = "/tmp/ca.pem"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.etcd_domain.address[count.index]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "output/etcd.pem"
    destination = "/tmp/etcd.pem"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.etcd_domain.address[count.index]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "output/etcd-key.pem"
    destination = "/tmp/etcd-key.pem"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.etcd_domain.address[count.index]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "output/${module.etcd_domain.name[count.index]}.service"
    destination = "/tmp/etcd.service"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.etcd_domain.address[count.index]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "scripts/etcd.sh"
    destination = "/tmp/etcd.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.etcd_domain.address[count.index]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/etcd.sh",
      "sudo /tmp/etcd.sh"
    ]
    connection {
      host        = module.etcd_domain.address[count.index]
      user        = var.user
      private_key = file("~/.ssh/id_rsa")
    }
  }
}
