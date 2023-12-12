terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.38.1"
    }
  }
}

resource "proxmox_virtual_environment_vm" "node" {
  name                = var.name
  on_boot             = var.autostart
  node_name           = var.target_node
  bios                = "seabios"
  scsi_hardware       = "virtio-scsi-pci"
  timeout_shutdown_vm = 300
  tags                = ["alma-linux-9", "k8s"]

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 60
  }

  cpu {
    cores   = var.vcpus
    type    = "host"
    sockets = var.sockets
  }

  agent {
    enabled = true
    timeout = "10s"
  }

  clone {
    retries = 3
    vm_id   = 932
  }

  network_device {
    model  = "virtio"
    bridge = var.default_bridge
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      keys     = [var.ssh_key]
      username = var.user
    }
  }

}

data "external" "address" {
  depends_on  = [proxmox_virtual_environment_vm.node]
  working_dir = path.root
  program     = ["bash", "scripts/ip.sh", "${lower(proxmox_virtual_environment_vm.node.network_device[0].mac_address)}"]
}
