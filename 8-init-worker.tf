
resource "null_resource" "init-worker" {
  depends_on = [docker_container.etcd-gen, null_resource.etcd-config, module.master_domain, local_file.nginx_config, null_resource.join-first-master]
  count      = length(module.worker_domain)
  provisioner "file" {
    source      = "join-worker.sh"
    destination = "/tmp/join-worker.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.worker_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/join-worker.sh",
      "sudo /tmp/join-worker.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.worker_domain[count.index].address
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
