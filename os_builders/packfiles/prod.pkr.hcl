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

# Adapted from https://github.com/tylert/packer-build/blob/master/source/ubuntu/22.04_jammy/base.pkr.hcl
source "qemu" "ubuntu_2204" {
    iso_url             = "https://releases.ubuntu.com/jammy/ubuntu-22.04.2-live-server-amd64.iso"
    iso_checksum        = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
    disk_size           = "25G"
    output_directory    = "output"
    # Remove the packer user and shutdown the VM at the same time
    format              = "qcow2"
    accelerator         = "kvm"
    memory              = "4096"

    ssh_username        = "packer"
    ssh_password        = "packer"
    ssh_timeout         = "20m"
    
    shutdown_command    = "sudo su root -c \"userdel -rf packer; rm /etc/sudoers.d/90-cloud-init-users; /sbin/shutdown -hP now\""
    boot_wait           = "3s"
    http_directory      = "packfiles/ubuntu/http-server"
    boot_key_interval   = "65ms"  # If keys are being sent too fast and causing errors increase this
    boot_command        =  [
    "<esc><esc>c",
    "linux /casper/vmlinuz \"ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" --- autoinstall",
    "<enter>",
    "<wait>",
    "initrd /casper/initrd",
    "<enter>",
    "<wait><wait><wait><wait><wait>",
    "boot",
    "<enter>",
    "<wait>"
  ]
}

build {
    sources = [
        "source.qemu.ubuntu_2204"
    ]


  provisioner "ansible" {
    playbook_file = "./image_prep.yml"
    extra_arguments = [
        # Include safety checks
        "--extra-vars", "provision_this_machine=true",
        # Workaround https://github.com/hashicorp/packer/issues/12416
        #"--scp-extra-args", "'-O'",
        #"--ssh-extra-args", "-o IdentitiesOnly=yes -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa"
    ]
  }
}