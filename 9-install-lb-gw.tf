resource "null_resource" "generte-metallb-istio" {
  provisioner "local-exec" {
    command = "cp -r ${path.root}/templates/metal-ip.tmpl metal-ip.yaml"
  }
  provisioner "local-exec" {
    command = "sed -i -e 's/metallb_load_balancer_ip/${var.metallb_load_balancer_ip}/g' metal-ip.yaml"
  }
  provisioner "local-exec" {
    command = "cp -r ${path.root}/templates/istio.tmpl istio.sh"
  }
  provisioner "local-exec" {
    command = "sed -i -e 's/istio_version_re/${var.istio_version}/g' istio.sh"
  }
}
resource "local_file" "metallb-ip" {
  content = templatefile("${path.root}/templates/metal-ip.tmpl",
    {
      metallb_load_balancer_ip = var.metallb_load_balancer_ip
    }
  )
  filename = "metal-ip.yaml"
}
resource "local_file" "istio-sh" {
  content = templatefile("${path.root}/templates/istio.tmpl",
    {
      istio_version = var.istio_version
    }
  )
  filename = "istio.sh"
}

resource "null_resource" "install-lb-gw" {
  depends_on = [null_resource.init-worker, null_resource.generte-metallb-istio]
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
