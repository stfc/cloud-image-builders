# cloud-image-builders
Builders for various cloud images. See each README for more information.

Contents
========

- Amphora image builder

This is a tool to build an amphora image for use with OpenStack Octavia.

- OS Builders

A directory containing all publicly available generic images (excluding Cluster API)
which share common packer build roles

- K8s Image Builder

A git submodule containing the upstream Kubernetes image builder.
This is used with packer JSON to include custom STFC roles from the OS Builders directory.

Requirements
============

- Docker (Amphora Only)
- Ansible
- Packer and QEMU - This can be installed by running the `prep_builder.yml` playbook
  in the `os_builders` directory. See the README there for more information.

K8s Image Builder
=================

Building a specific image
-------------------------

- Grab the latest version of the K8s Image Builder submodule:

```
git submodule update --init --recursive
```

- Build the image, pointing to our custom roles:

```
export PACKER_VAR_FILES="$(pwd)/cluster-api/ansible_stfc_roles.json"
make -C k8s-image-builder/images/capi build-qemu-ubuntu-2004
```

- To build a custom version of the image, you can specify the version of the
  image builder to use:

```
# E.g. to build 1.25.x
export K8S_VERSION="cluster-api/versions/v1_25.json"
export ROLE_DEFINITION="cluster-api/ansible_stfc_roles.json"
export PACKER_VAR_FILES="$(pwd)/${K8S_VERSION} $(pwd)/${ROLE_DEFINITION}"
make -C k8s-image-builder/images/capi build-qemu-ubuntu-2004
```
