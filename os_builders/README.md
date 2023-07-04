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


Development and Testing
========================

Packer uses a multi stage build. Stage 1 will build the VM image using auto-install. Stage 2 will provision the image with any customisations we want.

This allows us to rapidly iterate on our customisations without having to wait for the OS install to complete.

Preparing a builder
-------------------

To build locally, you need to have the following installed:
- ansible

Then run the following command:
```
ansible-playbook -i inventory/localhost builder.yml --ask-become-pass
```

Directory Layout
----------------

- `packfiles/` - Packer templates for building the VM images
- `packfiles/ubuntu_sources.pkr.hcl` - Contains image definitions for Ubuntu
- `packfiles/rocky_sources.pkr.hcl` - Contains image definitions for Rocky (TODO)
- `packfiles/build.pkr.hcl` - Contains the build steps for the VM image. This uses a two stage build described below

CI/CD Files:

- `packfiles/headless.pkrvars.hcl` - Contains the variables for doing a headless build


Testing New OS Variants
--------------------------
It's recommended you run this locally, so that you can see the VNC window and debug any issues:

- Ensure the builder is configured, as above
- Add your new build to the sources file, you need to add a base step and a provisioning step. See the Ubuntu file for an example.
- Run your new/modified stage 1 build through the auto-install step: `cd packerfiles && packer build --only=stage1*<name>*` 

For example:
`cd packerfiles && packer build --only=stage1*ubuntu_2204 .`

- Test the provisioning step on your new image:
`cd packerfiles && packer build --only=stage2*<name>*`


Prototyping new Ansible changes on a VM
----------------------------------------
It's recommended you use an existing VM for this testing, as it will be quicker than running an OS install and uploading :

- Add your hosts to a testing inventory file, e.g. `cat inventory/testing.yml`:

```
all:
    hosts:
        host-172-16-255-255.nubes.stfc.ac.uk:
            ansible_user: ubuntu  # or rocky
```

**Ensure you are on a VM!**

The `provision_this_machine` variable acts as a guard from trashing your own machine. 

- Run the playbook
```
ansible-playbook -i inventory/testing.yml image_prep.yml --extra-vars provision_this_machine=true
```

