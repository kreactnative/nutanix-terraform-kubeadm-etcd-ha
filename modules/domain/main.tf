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

/*resource "nutanix_subnet" "k8s-subnet" {
  name         = "k8s-subnet"
  cluster_uuid = data.nutanix_cluster.cluster.cluster_id
  vlan_id      = 0
  subnet_type  = "VLAN"

  prefix_length              = 24
  default_gateway_ip         = "192.168.1.1"
  subnet_ip                  = "192.168.1.225/16"
  ip_config_pool_list_ranges = ["192.168.1.225 192.168.1.250"]

  dhcp_domain_name_server_list = ["8.8.8.8", "1.1.1.1"]
}*/

data "nutanix_subnet" "subnet" {
  subnet_name = "k8s-subnet"
}

resource "nutanix_virtual_machine" "vm" {
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
