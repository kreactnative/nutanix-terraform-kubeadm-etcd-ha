resource "null_resource" "install-lb-gw" {
  depends_on = [local_file.metallb, local_file.istio, null_resource.join-first-master, null_resource.init-other-master, null_resource.init-worker]

  provisioner "file" {
    source      = "k8s/istio-operator.yaml"
    destination = "/tmp/istio-operator.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain.address[0]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/istio.yaml"
    destination = "/tmp/istio.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain.address[0]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "metal-ip.yaml"
    destination = "/tmp/metal-ip.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain.address[0]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/metric-server.yaml"
    destination = "/tmp/metric-server.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain.address[0]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "k8s/ssl.yaml"
    destination = "/tmp/ssl.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain.address[0]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "istio.sh"
    destination = "/tmp/istio.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain.address[0]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/istio.sh",
      "sudo /tmp/istio.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain.address[0]
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
