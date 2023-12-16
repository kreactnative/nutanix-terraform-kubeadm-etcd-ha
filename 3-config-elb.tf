resource "local_file" "nginx_config" {
  depends_on = [
    module.master_domain,
    module.elb_domain
  ]
  content = templatefile("${path.root}/templates/nginx.tmpl",
    {
      node_map_masters = zipmap(
        tolist(module.master_domain.address[*].ip), tolist(module.master_domain.name[*])
      ),
    }
  )
  filename = "nginx.conf"
  provisioner "file" {
    source      = "${path.root}/nginx.conf"
    destination = "/tmp/nginx.conf"
    connection {
      type        = "ssh"
      host        = module.elb_domain.address[0].ip
      user        = var.user
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "file" {
    source      = "scripts/nginx.sh"
    destination = "/tmp/nginx.sh"
    connection {
      type        = "ssh"
      host        = module.elb_domain.address[0].ip
      user        = var.user
      private_key = file("~/.ssh/id_rsa")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/nginx.sh",
      "sudo /tmp/nginx.sh"
    ]
    connection {
      host        = module.elb_domain.address[0].ip
      user        = var.user
      private_key = file("~/.ssh/id_rsa")
    }
  }
}
