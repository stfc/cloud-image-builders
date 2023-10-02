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
  }
}

variable "headless" {
  type = bool
  default = false
}

locals {
    # Generic
    disk_size   = "25G"
    auto_install_output = "base_output"
    output_directory    = "output"
    output_format       = "qcow2"
    accelerator         = "kvm"
    memory              = "4096"
    # If keys are being sent too fast and causing errors increase this
    boot_key_interval   = "65ms"  

    ssh_username        = "packer"
    ssh_password        = "packer"
    ssh_timeout         = "20m"
    
    # Remove the packer user and shutdown the VM at the same time
    shutdown_command    = "sudo -S shutdown -P now"
    
    # Ubuntu Specific
    ubuntu_http_directory = "ubuntu/http-server"
}

# Sets options which are default across all Ubuntu builders
# Adapted from https://github.com/tylert/packer-build/blob/master/source/ubuntu/22.04_jammy/base.pkr.hcl
source "qemu" "ubuntu_2204_base" {
    iso_url             = "https://releases.ubuntu.com/jammy/ubuntu-22.04.3-live-server-amd64.iso"
    iso_checksum        = "a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
    disk_size           = local.disk_size
    output_directory    = local.auto_install_output
    # Remove the packer user and shutdown the VM at the same time
    format              = local.output_format
    accelerator         = local.accelerator
    memory              = local.memory
    headless            = var.headless

    ssh_username        = local.ssh_username
    ssh_password        = local.ssh_password
    ssh_timeout         = local.ssh_timeout
    
    shutdown_command    = local.shutdown_command
    http_directory      = local.ubuntu_http_directory
    boot_key_interval   = local.boot_key_interval
    boot_wait           = "5s"
    boot_command        = ["<esc><esc>c",
                           "linux /casper/vmlinuz \"ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" --- autoinstall",
                            "<enter>","<wait>",
                            "initrd /casper/initrd",
                            "<enter>","<wait><wait><wait><wait><wait>",
                            "boot","<enter>","<wait>"]
}

source "qemu" "ubuntu_2204_provision" {
    iso_url             = "${local.auto_install_output}/packer-ubuntu_2204_base"
    disk_image          = true
    iso_checksum        = "none"
    disk_size           = local.disk_size

    output_directory    = local.output_directory
    # Remove the packer user and shutdown the VM at the same time
    format              = local.output_format
    accelerator         = local.accelerator
    memory              = local.memory
    headless            = var.headless

    ssh_username        = local.ssh_username
    ssh_password        = local.ssh_password
    ssh_timeout         = local.ssh_timeout
    
    shutdown_command    = local.shutdown_command
    boot_wait           = "5s"
}
