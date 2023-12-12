resource "null_resource" "control-plane-config" {
  depends_on = [docker_container.etcd-gen, null_resource.etcd-config, module.master_domain, local_file.nginx_config]
  count      = length(module.master_domain)
  provisioner "file" {
    source      = "output/ca.pem"
    destination = "/home/${var.user}/ca.pem"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "output/etcd.pem"
    destination = "/home/${var.user}/etcd.pem"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "output/etcd-key.pem"
    destination = "/home/${var.user}/etcd-key.pem"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "scripts/setup-k8s.sh"
    destination = "/home/${var.user}/setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/${var.user}/setup-k8s.sh",
      "sudo /home/${var.user}/setup-k8s.sh",
      "sudo sh -c  \"echo '${module.master_domain[count.index].address} ${module.master_domain[count.index].name}' > /etc/hosts\""
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
