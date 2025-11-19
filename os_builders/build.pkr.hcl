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
  metadata = {
    "hw_machine_type" : "q35",
    "hw_disk_bus" : "scsi",
    "hw_firmware_type" : "uefi",
    "hw_qemu_guest_agent" : "yes",
    "hw_scsi_model" : "virtio-scsi",
    "hw_vif_multiqueue_enabled" : "true",
    "os_require_quiesce" : "yes"
  }
  aq_metadata = {
    "AQ_ARCHETYPE": "cloud",
    "AQ_DOMAIN": "prod_cloud",
    "aq_managed": "true",
    "AQ_OS": "rocky",
    "AQ_OSNAME": "rocky",
    "AQ_PERSONALITY": "nubesvms",
  }
}

source "openstack" "builder" {
  domain_name       = "Default"
  flavor            = "l3.nano"
  security_groups   = ["default"]
  networks          = [""]  # OpenStack External Network ID
  image_visibility  = "private"
  ssh_timeout       = "20m"
}

build {
  source "openstack.builder" {
    name                      = "ubuntu-jammy"
    image_name                = "ubuntu-jammy-22.04-nogui-${ local.date_suffix }"
    ssh_username              = "ubuntu"
    external_source_image_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
    metadata                  = local.metadata
  }
  source "openstack.builder" {
    name                      = "ubuntu-noble"
    image_name                = "ubuntu-noble-24.04-nogui-${ local.date_suffix }"
    ssh_username              = "ubuntu"
    external_source_image_url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    metadata                  = local.metadata
  }
  source "openstack.builder" {
    name                      = "ubuntu-azimuth"
    external_source_image_url = "https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_f0dc9cb312144d0aa44037c9149d2513/azimuth-images/ubuntu-jammy-desktop-250701-1116.qcow2"
    image_name                = "test-azimuth"
    ssh_username              = "ubuntu"
    metadata                  = local.metadata
  }
  source "openstack.builder" {
    name = "rocky-8"
    image_name = "rocky-8-nogui-${ local.date_suffix }"
    ssh_username = "rocky"
    external_source_image_url = "https://www.mirrorservice.org/sites/download.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"    
    metadata                  = local.metadata
  }
    source "openstack.builder" {
    name = "rocky-9"
    image_name = "rocky-9-nogui-${ local.date_suffix }"
    ssh_username = "rocky"
    external_source_image_url = "https://www.mirrorservice.org/sites/download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
    metadata                  = local.metadata
  }
    source "openstack.builder" {
    name = "rocky-8-aq"
    image_name = "rocky-8-aq-${ local.date_suffix }"
    ssh_username = "rocky"
    external_source_image_url = "https://www.mirrorservice.org/sites/download.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"
    metadata                  = merge(local.metadata, local.aq_metadata, {"AQ_OSVERSION": "8x-x86_64"})
  }
    source "openstack.builder" {
    name = "rocky-9-aq"
    image_name = "rocky-9-aq-${ local.date_suffix }"
    ssh_username = "rocky"
    external_source_image_url = "https://www.mirrorservice.org/sites/download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
    metadata                  = merge(local.metadata, local.aq_metadata, {"AQ_OSVERSION": "9x-x86_64"})
  }

  sources = ["openstack.builder"]

  provisioner "ansible" {
    user          = "${build.User}"
    playbook_file = "vm_baseline.yml"
    extra_arguments = [
      # Workaround https://github.com/hashicorp/packer/issues/12416
      "--scp-extra-args", "'-O'",
    ]
  }

  provisioner "ansible" {
    user          = "${build.User}"
    playbook_file = "image_fixes.yml"
    extra_arguments = [
      # Workaround https://github.com/hashicorp/packer/issues/12416
      "--scp-extra-args", "'-O'",
    ]
  }
  
  provisioner "ansible" {
    user          = "${build.User}"
    playbook_file = "tidy_image.yml"
    extra_arguments = [
      # Workaround https://github.com/hashicorp/packer/issues/12416
      "--scp-extra-args", "'-O'",
    ]
  }
  provisioner "ansible" {
    only = ["openstack.rocky-8-aq", "openstack.rocky-9-aq"]
    user          = "${build.User}"
    playbook_file = "quattor.yml"
    extra_arguments = [
      # Workaround https://github.com/hashicorp/packer/issues/12416
      "--scp-extra-args", "'-O'",
    ]
  }
}
