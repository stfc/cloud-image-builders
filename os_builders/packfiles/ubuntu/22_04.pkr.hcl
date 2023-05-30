# Adapted from https://github.com/tylert/packer-build/blob/master/source/ubuntu/22.04_jammy/base.pkr.hcl

source "qemu" "ubuntu_2204" {
    iso_url             = "https://releases.ubuntu.com/jammy/ubuntu-22.04.2-live-server-amd64.iso"
    iso_checksum        = "sha256:5e38b55d57d94ff029719342357325ed3bda38fa80054f9330dc789cd2d43931"
    output_directory    = "output-ubuntu-2204"
    shutdown_command    = "sudo shutdown -P now"
    # TODO
    disk_size           = "10G"
    memory              = "4096"
    format              = "qcow2"
    accelerator         = "kvm"

    ssh_username        = "builder"
    ssh_password        = "builder"
    ssh_timeout         = "20m"
    
    boot_wait           = "2s"
    http_directory      = "ubuntu/http-server"
    boot_key_interval   = "25ms"  # If keys are being sent too fast and causing errors increase this
    boot_command        =  [
    "<esc><esc>c",
    "linux /casper/vmlinuz \"ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" --- autoinstall",
    "<enter>",
    "initrd /casper/initrd",
    "<enter>",
    "<wait>",
    "boot",
    "<enter>",
    "<wait>"
  ]
}

build {
    sources = [
        "source.qemu.ubuntu_2204"
    ]


  provisioner "shell" {
    binary            = false
    execute_command   = "sudo -E '{{ .Path }}'"
    expect_disconnect = true
    inline = [
      "apt-get update",
      "apt-get --yes dist-upgrade",
      "apt-get clean"
    ]
    inline_shebang      = "/bin/sh -e"
    only                = ["qemu", "vbox"]
    skip_clean          = false
    start_retry_timeout = var.start_retry_timeout
  }

}