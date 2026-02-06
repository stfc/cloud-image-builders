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
  date_suffix = "${formatdate("YYYY-MM-DD", timestamp())}"
}

source "openstack" "builder" {
  domain_name       = "Default"
  flavor            = "l3.nano"
  security_groups   = ["default"]
  networks          = ["fa2f5ebe-d0e0-4465-9637-e9461de443f1"]  # Dev OpenStack Network ID
  image_visibility  = "private"
  ssh_timeout       = "20m"
  metadata = {
    "hw_machine_type" : "q35",
    "hw_disk_bus" : "scsi",
    "hw_qemu_guest_agent" : "yes",
    "hw_scsi_model" : "virtio-scsi",
    "hw_vif_multiqueue_enabled" : "true",
    "os_require_quiesce" : "yes",
    # This must be set to BIOS to avoid problems where NVIDIA drivers expect BAR support
    # (as we are in EFI mode) but our host HVs are still in BIOS mode.
    # "NVRM: This PCI I/O region assigned to your NVIDIA device is invalid:"
    # "NVRM: BAR0 is 0M @ 0x0", where the BAR offered is a 0MB region so obviously invalid.
    # Once we're RL9 + EFI + Above 4GB decoding everywhere we can enable EFI which gives
    # some perf benefits for GPU passthrough where REBAR can be used
    "hw_firmware_type" : "bios"
  }
}

build {
  source "openstack.builder" {
    name                      = "ubuntu-jammy"
    image_name                = "ubuntu-jammy-22.04-nogui-${ local.date_suffix }"
    ssh_username              = "ubuntu"
    external_source_image_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  }
  source "openstack.builder" {
    name                      = "ubuntu-noble"
    image_name                = "ubuntu-noble-24.04-nogui-${ local.date_suffix }"
    ssh_username              = "ubuntu"
    external_source_image_url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  }
  source "openstack.builder" {
    name = "rocky-8"
    image_name = "rocky-8-nogui-${ local.date_suffix }"
    ssh_username = "rocky"
    external_source_image_url = "https://www.mirrorservice.org/sites/download.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"    
  }
    source "openstack.builder" {
    name = "rocky-9"
    image_name = "rocky-9-nogui-${ local.date_suffix }"
    ssh_username = "rocky"
    external_source_image_url = "https://www.mirrorservice.org/sites/download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  }

  source "openstack.builder" {
    name                      = "azimuth-workstation"
    external_source_image_url = "https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_f0dc9cb312144d0aa44037c9149d2513/azimuth-images/ubuntu-jammy-desktop-251029-1115.qcow2"
    image_name                = "azimuth-workstation-${ local.date_suffix }"
    ssh_username              = "ubuntu"
  }
  source "openstack.builder" {
    name                      = "azimuth-rstudio"
    external_source_image_url = "https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_f0dc9cb312144d0aa44037c9149d2513/azimuth-images/ubuntu-jammy-linux-rstudio-251029-1117.qcow2"
    image_name                = "azimuth-rstudio-${ local.date_suffix }"
    ssh_username              = "ubuntu"
  }
  source "openstack.builder" {
    name                      = "azimuth-jupyter-repo2docker"
    external_source_image_url = "https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_f0dc9cb312144d0aa44037c9149d2513/azimuth-images/ubuntu-jammy-jupyter-repo2docker-251029-1115.qcow2"
    image_name                = "azimuth-jupyter-repo2docker-${ local.date_suffix }"
    ssh_username              = "ubuntu"
  }

  sources = ["openstack.builder"]

  provisioner "ansible" {
    user          = "${build.User}"
    playbook_file = "configure_os_images.yml"
    extra_arguments = [
      # Workaround https://github.com/hashicorp/packer/issues/12416
      # This is required for Ubuntu (Debian) 24.04+ as SFTP is disabled by default
      "--scp-extra-args", "'-O'",
    ]
  }
}

