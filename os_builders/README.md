Image Building
==============

To build locally, you need to have the following installed:
- ansible

Then run the following command:
```
ansible-playbook -i inventory/localhost builder.yml --ask-become-pass
```

Tags
----

TODO

Testing New Packer Variants
---------------------------

- Run setup tag: `ansible-playbook -i inventory/localhost builder.yml --ask-become-pass --tags setup`
- cd into the packer directory: `cd /tmp/packer/packfiles`
- Run your new/modified build, e.g. `packer build ubuntu/22_04.pkr.hcl`

Getting Ubuntu Kickstart Working
--------------------------------

See https://ubuntu.com/server/docs/install/autoinstall-quickstart

Testing new Ansible roles on a VM
----------------------------------
- Add your machine to a testing inventory file, e.g. `cat inventory/testing.yml`:

```
all:
    hosts:
        host-172-16-255-255.nubes.stfc.ac.uk:
            ansible_user: ubuntu
```


```
ansible-playbook -i inventory/testing.yml image_prep.yml --extra-vars provision_this_machine=true
```

**If you use the localhost inventory ensure you are on a VM!**

The `provision_this_machine` variable acts as a guard from trashing your own machine. 

```