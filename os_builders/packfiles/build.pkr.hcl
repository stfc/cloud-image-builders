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

source "openstack" "builder" {
  domain_name       = "Default"
  flavor            = "l3.nano"
  security_groups   = ["default"]
  networks          = ["5be315b7-7ebd-4254-97fe-18c1df501538"]
  image_visibility  = "private"
  ssh_timeout       = "20m"
  metadata = {
    "hw_machine_type" : "q35",
    "hw_disk_bus" : "scsi",
    "hw_firmware_type" : "uefi",
    "hw_qemu_guest_agent" : "yes",
    "hw_scsi_model" : "virtio-scsi",
    "hw_vif_multiqueue_enable" : "true",
    "os_require_quiesce" : "yes"
  }
}

build {
  source "openstack.builder" {
    name                      = "ubuntu-jammy"
    image_name                = "ubuntu-jammy-22.04-nogui-latest-baseline"
    ssh_username              = "ubuntu"
    external_source_image_url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  }
  source "openstack.builder" {
    name                      = "ubuntu-azimuth"
    external_source_image_url = "https://object.arcus.openstack.hpc.cam.ac.uk/swift/v1/AUTH_f0dc9cb312144d0aa44037c9149d2513/azimuth-images/ubuntu-jammy-desktop-250701-1116.qcow2"
    image_name                = "test-azimuth"
    ssh_username              = "ubuntu"
  }
  source "openstack.builder" {
    name = "rocky-8"
    image_name = "rocky-8-nogui-latest-baseline"
    ssh_username = "rocky"
    external_source_image_url = "https://dl.rockylinux.org/pub/rocky/8/images/x86_64/Rocky-8-GenericCloud.latest.x86_64.qcow2"
  }
    source "openstack.builder" {
    name = "rocky-9"
    image_name = "rocky-9-nogui-latest-baseline"
    ssh_username = "rocky"
    external_source_image_url = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
  }

  sources = ["openstack.builder"]

  provisioner "ansible" {
    user          = "${build.User}"
    playbook_file = "${path.root}/../playbooks/prepare_user_image.yml"
    extra_arguments = [
      # Include safety checks
      "--extra-vars", "provision_this_machine=true, tidy_image=True",
      # Workaround https://github.com/hashicorp/packer/issues/12416
      "--scp-extra-args", "'-O'",
      #"--ssh-extra-args", "-o IdentitiesOnly=yes -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa"
    ]
  }
}

