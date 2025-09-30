build {
  name    = ""
  sources = ["source.openstack.ubuntu_2204"]

  provisioner "ansible" {
    user          = "ubuntu"
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

build {
  name    = "azimuth_ubuntu"
  sources = ["source.openstack.test_ubuntu"]

  provisioner "ansible" {
    user          = "ubuntu"
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