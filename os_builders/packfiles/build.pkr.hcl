build {
  name = "stage-1"

  sources = [
    "source.qemu.ubuntu_2204_base"
]
}

build{
  name = "stage-2"

  sources = [
    "source.qemu.ubuntu_2204_provision"
  ]

  provisioner "ansible" {
  playbook_file = "../provision_image.yml"
  extra_arguments = [
      # Include safety checks
      "--extra-vars", "provision_this_machine=true",
      # Workaround https://github.com/hashicorp/packer/issues/12416
      "--scp-extra-args", "'-O'",
      "--ssh-extra-args", "-o IdentitiesOnly=yes -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa"
  ]
  }
}