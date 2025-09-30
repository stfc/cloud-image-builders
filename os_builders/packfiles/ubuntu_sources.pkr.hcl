packer {
  required_plugins {
    ansible = {
      version = " >= 1.0.4"
      source  = "github.com/hashicorp/ansible"
    }
    openstack = {
      version = " >= 1.1.2"
      source  = "github.com/hashicorp/openstack"
    }
  }
}

locals {
  # Generic
  identity_endpoint         = "https://openstack.stfc.ac.uk:5000"
  flavor                    = "l3.tiny"
  security_groups           = ["default"]
  networks                  = ["5be315b7-7ebd-4254-97fe-18c1df501538"]
  volume_size = 25
  image_min_disk = 25
  image_visibility = "private"
  output_format       = "qcow2"
  ssh_username = "ubuntu"
  ssh_timeout  = "20m"
}

source "openstack" "ubuntu_2204" {
  external_source_image_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img"
  image_name                = "ubuntu-jammy"

  identity_endpoint         = local.identity_endpoint
  flavor                    = local.flavor
  security_groups           = local.security_groups
  networks                  = local.networks
  use_blockstorage_volume   = local.use_blockstorage_volume
  image_disk_format         = local.output_format
  volume_size               = local.volume_size
  image_min_disk            = local.image_min_disk
  image_visibility          = local.image_visibility

  ssh_username              = local.ssh_username
  ssh_timeout               = local.ssh_timeout
}

source "openstack" "azimuth_ubuntu" {
  external_source_image_url = "https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_f0dc9cb312144d0aa44037c9149d2513/azimuth-images/ubuntu-jammy-desktop-250701-1116.qcow2"    
  image_name                = "test-azimuth"

  identity_endpoint         = local.identity_endpoint
  flavor                    = local.flavor
  security_groups           = local.security_groups
  networks                  = local.networks
  use_blockstorage_volume   = local.use_blockstorage_volume
  image_disk_format         = local.output_format
  volume_size               = local.volume_size
  image_min_disk            = local.image_min_disk
  image_visibility          = local.image_visibility

  ssh_username              = local.ssh_username
  ssh_timeout               = local.ssh_timeout
}