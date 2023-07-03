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

Preparing a builder
-------------------

To build locally, you need to have the following installed:
- ansible

Then run the following command:
```
ansible-playbook -i inventory/localhost builder.yml --ask-become-pass
```

Alternatively, add your VM to a yaml file (e.g. `inventory/testing.yml`) and run:

```
ansible-playbook -i inventory/testing.yml builder.yml
```

Testing New OS Variants
--------------------------
It's recommended you run this locally, so that you can see the VNC window and debug any issues:

- Ensure the builder is configured, as above
- Run your new/modified build, e.g. `packer build packfiles`
- A specific OS can be tested by using `packer build -only=ubuntu-20.04 packfiles` for example


Testing new Ansible roles on a VM
----------------------------------
It's recommended you use an existing VM for this testing, as it will be quicker than running an OS install:


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

