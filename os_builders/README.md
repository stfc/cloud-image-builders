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