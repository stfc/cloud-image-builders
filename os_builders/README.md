Image Building
==============

This directory contains the Ansible playbooks and Packer templates for building the VM images.
It sets a baseline for all VMs to comply with our security policies, in an OS agnostic way.

Pipeline
--------

The pipeline consists of the following steps:

- Packer builds the VM image, with a packer user and password set to `packer`
- The VM is booted and Ansible is run to configure the VM using the `image_prep.yml` playbook
- The image is tidied, the packer user is deleted and the VM shuts down. 
- Packer converts this to a qcow2 image ready for upload.

*Note: This script does not upload or test the image, this is done separately currently*

Building Locally
=================

The easiest way is to run the Ansible playbooks which will prepare the current machine, and
also handle the multi-stage builds.

Preparing a builder
-------------------

To build locally, you need to have the following installed:
- ansible

First, install required ansible collections:
```
ansible-galaxy install -r requirements.yml
```

- Then run the following command to install packer and prep the environment:


```
ansible-playbook -i inventory/localhost playbooks/prep_builder.yml --ask-become-pass
```

Note: This tooling assumes you are using dev-openstack (e.g. for Network ID), as we should not be
building images on production, as packer will upload and delete temporary images as part of the steps.

- Create OpenStack application credentials using Horizon or "openstack application credential create" . Admin is *not* required.
- Export the following environment variables in your shell:

```
export OS_AUTH_URL=https://dev-openstack.stfc.ac.uk:5000/v3
export OS_APPLICATION_CREDENTIAL_ID=<app_cred_id>
export OS_APPLICATION_CREDENTIAL_SECRET=<app_cred_secret>
```

Running the build
--------------------

Images can be built with the following command
```
ansible-playbook -i inventory/localhost playbooks/builder.yml
````

This will build all images (it implies the `all` tag). Individual tags can be selected as follows

```
ansible-playbook -i inventory/localhost playbooks/builder.yml -t <tag>
````

The following tags are available:
- `all` - Build all images (default)
- `ubuntu` - Build all Ubuntu variants
- `ubuntu_2204` - Build Ubuntu 22.04



Directory Layout
----------------

- `packfiles/` - Packer templates for building the VM images
- `packfiles/build.pkr.yml` - OpenStack builder definitions


Prototyping new Ansible changes on a VM
----------------------------------------
It's recommended you use an existing VM for this testing, as it will be quicker than running an OS install and uploading :

- Add your hosts to a testing inventory file, e.g. `cat inventory/testing.yml`:

```
all:
    hosts:
        test-vm:
            ansible_user: ubuntu  # or rocky
            ansible_host: "172.16.255.255"
```

**Ensure you are on a VM!**

The `provision_this_machine` variable acts as a guard from trashing your own machine. 

- Run the playbook
```
ansible-playbook -i inventory/testing.yml playbooks/prepare_user_image.yml
```

Troubleshooting Packer Builds
-----------------------------

If packer fails or hangs you can manually run a build to get a live output and/or add debug flags:

```shell
cd os_builders/packfiles
export PACKER_LOG=1
packer build --force --only='openstack.os-variant' build.pkr.hcl  # variant in build.pkr.hcl
```
