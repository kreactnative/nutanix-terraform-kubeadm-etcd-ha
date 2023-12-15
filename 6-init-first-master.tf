resource "local_file" "cluster_config" {
  depends_on = [
    module.etcd_domain,
    module.elb_domain,
    null_resource.control-plane-config
  ]
  content = templatefile("${path.root}/templates/config.tmpl",
    {
      loadbalancer_ip = module.elb_domain[0].address,
      node_etcds = zipmap(
        tolist(module.etcd_domain[*].address), tolist(module.etcd_domain[*].address)
      )
    }
  )
  filename = "cluster.yaml"
}
resource "local_file" "helm_ciliun_config" {
  depends_on = [
    module.etcd_domain,
    module.elb_domain,
    null_resource.control-plane-config
  ]
  content = templatefile("${path.root}/templates/helm-cni-lb.tmpl",
    {
      loadbalancer_ip = module.elb_domain[0].address
    }
  )
  filename = "helm-cni-lb.sh"
}
resource "null_resource" "join-first-master" {
  depends_on = [local_file.cluster_config, module.master_domain, module.etcd_domain, module.elb_domain, local_file.nginx_config, local_file.helm_ciliun_config]
  provisioner "file" {
    source      = "cluster.yaml"
    destination = "/tmp/cluster.yaml"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "scripts/kube-init.sh"
    destination = "/tmp/kube-init.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "helm-cni-lb.sh"
    destination = "/tmp/helm-cni-lb.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/kube-init.sh",
      "sudo /tmp/kube-init.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/helm-cni-lb.sh",
      "sudo /tmp/helm-cni-lb.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain[0].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ${var.user}@${module.master_domain[0].address}:/tmp/config $HOME/.kube/nutanix-k8s-ha-config"
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ${var.user}@${module.master_domain[0].address}:/tmp/join-master.sh join-master.sh"
  }
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/id_rsa ${var.user}@${module.master_domain[0].address}:/tmp/join-worker.sh join-worker.sh"
  }
}
