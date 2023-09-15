Requirements
============

- Ansible  # apt/dnf package is fine

Setup
-----

- Install Ansible
- cd to the `os_builders` directory
- Configure the local machine / VM to be a builder:

```shell
cd os_builders

# If sudo is passwordless:
ansible-playbook -i inventory/localhost prep_builder.yml

# If password is required for sudo:
ansible-playbook -i inventory/localhost prep_builder.yml --ask-become-pass
```
- Log out and back in again to ensure the groups are applied
```shell
groups | grep -i kvm  # no output
exit
# ssh <user>@<host>
groups | grep -i kvm  # output: kvm
```

Rate Limiting
-------------

You may run into GitHub rate limiting issues when building images. To avoid this, you can set the following environment variable:

`PACKER_GITHUB_API_TOKEN=<token>`

The token can be generated from your GitHub settings, under developer access, and only needs the `public_repo` scope (i.e. the default).

Building the latest image
=========================

- Grab the latest version of the K8s Image Builder submodule:

```shell
cd ..  # back to repo root
git submodule update --init --recursive

# Point to our custom roles:
export ANSIBLE_ROLES_PATH="$(pwd)/os_builders/roles:$(pwd)/cluster-api/roles"
export PACKER_VAR_FILES="$(pwd)/cluster-api/ansible_stfc_roles.json"

# Run build
make -C k8s-image-builder/images/capi build-qemu-ubuntu-2004
```

Building a custom version
=========================

To build a custom version of the image, you can specify the version of the image builder to use additional variables to override the default role definition file:

```shell
# E.g. to build 1.25.x
cd .. # back to repo root
export ANSIBLE_ROLES_PATH="$(pwd)/os_builders/roles:$(pwd)/cluster-api/roles"
export K8S_VERSION="cluster-api/versions/v1_25.json"
export ROLE_DEFINITION="cluster-api/ansible_stfc_roles.json"

export PACKER_VAR_FILES="$(pwd)/${K8S_VERSION} $(pwd)/${ROLE_DEFINITION}"

make -C k8s-image-builder/images/capi build-qemu-ubuntu-2004
```

Adding a new version
====================
- Navigate to https://kubernetes.io/releases/
- Find the version you want to add or update
- Update the semver in the relevant JSON file. There should be a 1:1 mapping of
JSON files to major versions of Kubernetes. E.g. a file for 1.24, 1.25, etc.


Developer Notes
---------------
Since we cannot add comments to JSON files I've documented some points here:

- Currently we need to manually update minor versions of Kubernetes. We need to investigate how to update this long-term.
- We need to maintain multiple images in the past, as an upgrade can only do n+1 versions at a time.
- There's no check that git-submodules are up to date, so we need to manually update them.
