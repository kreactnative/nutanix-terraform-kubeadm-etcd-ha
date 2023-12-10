
resource "null_resource" "install-lb-gw" {
  depends_on = [null_resource.join-first-master, null_resource.init-other-master, null_resource.init-worker]

  provisioner "file" {
    source      = "k8s/istio-operator.yaml"
    destination = "/home/${var.user}/istio-operator.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/istio.yaml"
    destination = "/home/${var.user}/istio.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/metal-ip.yaml"
    destination = "/home/${var.user}/metal-ip.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/metric-server.yaml"
    destination = "/home/${var.user}/metric-server.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/ssl.yaml"
    destination = "/home/${var.user}/ssl.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "scripts/istio.sh"
    destination = "/home/${var.user}/istio.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/${var.user}/istio.sh",
      "sudo /home/${var.user}/istio.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
