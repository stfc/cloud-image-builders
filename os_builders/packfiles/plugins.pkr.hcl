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