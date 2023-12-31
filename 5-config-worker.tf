resource "null_resource" "worker-config" {
  depends_on = [docker_container.etcd-gen, null_resource.etcd-config, module.master_domain, local_file.nginx_config]
  count      = var.WORKER_COUNT
  provisioner "file" {
    source      = "scripts/setup-k8s.sh"
    destination = "/tmp/setup-k8s.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.worker_domain.address[count.index]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup-k8s.sh",
      "sudo /tmp/setup-k8s.sh",
      "sudo sh -c  \"echo '${module.worker_domain.address[count.index]} ${module.worker_domain.name[count.index]}' > /etc/hosts\""
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.worker_domain.address[count.index]
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
