
resource "null_resource" "init-other-master" {
  depends_on = [docker_container.etcd-gen, null_resource.etcd-config, module.master_domain, local_file.nginx_config, null_resource.join-first-master]
  count      = var.MASTER_COUNT - 1
  provisioner "file" {
    source      = "join-master.sh"
    destination = "/tmp/join-master.sh"
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain.address[count.index + 1]
      private_key = file("~/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/join-master.sh",
      "sudo /tmp/join-master.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.user
      host        = module.master_domain.address[count.index + 1]
      private_key = file("~/.ssh/id_rsa")
      timeout     = "20s"
    }
  }
}
