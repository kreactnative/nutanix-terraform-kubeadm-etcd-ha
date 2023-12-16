terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "1.2.0"
    }
  }
}

resource "nutanix_image" "image" {
  name        = "Alma Linux"
  description = "Alma Linux"
  source_uri  = "https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-9.3-20231113.x86_64.qcow2"
}

data "nutanix_cluster" "cluster" {
  name = "pertisk"
}

data "nutanix_subnet" "subnet" {
  subnet_name = "k8s-subnet"
}

resource "local_file" "cloudinit" {
  content = templatefile("templates/cloudinit.tmpl",
    {
      user    = var.user,
      ssh_key = var.ssh_key
    }
  )
  filename = "cloudinit.yaml"
}

resource "nutanix_virtual_machine" "vm" {
  depends_on           = [local_file.cloudinit]
  count                = var.VM_COUNT
  name                 = "${var.prefix_node_name}-0${count.index + 1}"
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = var.vcpus
  num_sockets          = var.sockets
  memory_size_mib      = var.memory
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = nutanix_image.image.id
    }
  }

  nic_list {
    subnet_uuid = data.nutanix_subnet.subnet.id
  }

  disk_list {
    disk_size_mib = 20000
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }
  }
  guest_customization_cloud_init_user_data = filebase64("./cloudinit.yaml")
}
