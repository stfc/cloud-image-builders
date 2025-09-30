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
    user          = "packer"
    playbook_file = "${path.root}/../playbooks/prepare_user_image.yml"
    extra_arguments = [
      # Include safety checks
      "--extra-vars", "provision_this_machine=true, tidy_image=True",
      # Workaround https://github.com/hashicorp/packer/issues/12416
      #"--scp-extra-args", "'-O'",
      #"--ssh-extra-args", "-o IdentitiesOnly=yes -o HostKeyAlgorithms=+ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa"
  ]
  }
}