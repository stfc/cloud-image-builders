packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.0.4"
      source  = "github.com/hashicorp/ansible"
    }
    openstack = {
      version = ">= 1.1.2"
      source  = "github.com/hashicorp/openstack"
    }
  }
}


variable "headless" {
  type    = bool
  default = false
}

locals {
  # Generic
  disk_size           = "25G"
  auto_install_output = "base_output"
  output_directory    = "output"
  output_format       = "qcow2"
  accelerator         = "kvm"
  memory              = "4096"
  # If keys are being sent too fast and causing errors increase this
  boot_key_interval = "65ms"

  ssh_username = "ubuntu"
  # ssh_password = "packer"
  ssh_timeout  = "20m"

  # Remove the packer user and shutdown the VM at the same time
  shutdown_command = "sudo -S shutdown -P now"

  # Ubuntu Specific
  ubuntu_http_directory = "ubuntu/http-server"
}

# Sets options which are default across all Ubuntu builders
# Adapted from https://github.com/tylert/packer-build/blob/master/source/ubuntu/22.04_jammy/base.pkr.hcl
#source "qemu" "ubuntu_2204_base" {
#  iso_url          = "https://releases.ubuntu.com/jammy/ubuntu-22.04.5-live-server-amd64.iso"
#  iso_checksum     = "9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
#  disk_size        = local.disk_size
#  output_directory = local.auto_install_output
#  # Remove the packer user and shutdown the VM at the same time
#  format      = local.output_format
#  accelerator = local.accelerator
#  memory      = local.memory
#  headless    = var.headless
#
#  ssh_username = local.ssh_username
#  ssh_password = local.ssh_password
#  ssh_timeout  = local.ssh_timeout
#
#  shutdown_command  = local.shutdown_command
#  http_directory    = local.ubuntu_http_directory
#  boot_key_interval = local.boot_key_interval
#  boot_wait         = "5s"
#  boot_command = ["<esc><esc>c",
#    "linux /casper/vmlinuz \"ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" --- autoinstall",
#    "<enter>", "<wait>",
#    "initrd /casper/initrd",
#    "<enter>", "<wait><wait><wait><wait><wait>",
#  "boot", "<enter>", "<wait>"]
#}

#source "qemu" "ubuntu_2204_provision" {
#  iso_url      = "${local.auto_install_output}/packer-ubuntu_2204_base"
#  disk_image   = true
#  iso_checksum = "none"
#  disk_size    = local.disk_size
#
#  output_directory = local.output_directory
#  # Remove the packer user and shutdown the VM at the same time
#  format      = local.output_format
#  accelerator = local.accelerator
#  memory      = local.memory
#  headless    = var.headless
#
#  ssh_username = local.ssh_username
#  ssh_password = local.ssh_password
#  ssh_timeout  = local.ssh_timeout
#
#  shutdown_command = local.shutdown_command
#  boot_wait        = "5s"
#}

source "openstack" "test_azimuth" {
  identity_endpoint         = "https://openstack.stfc.ac.uk:5000"
  flavor                    = "l3.tiny"
  image_name                = "test-azimuth-01-09-2025-v2"
  external_source_image_url = "https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_f0dc9cb312144d0aa44037c9149d2513/azimuth-images/ubuntu-jammy-desktop-250701-1116.qcow2"
  security_groups           = ["default"]
  networks                  = ["5be315b7-7ebd-4254-97fe-18c1df501538"]
  use_blockstorage_volume   = true
  image_disk_format = local.output_format
  volume_size = 25
  image_min_disk = 25
  image_visibility = "private"

  ssh_username = local.ssh_username
  ssh_timeout  = local.ssh_timeout
}
