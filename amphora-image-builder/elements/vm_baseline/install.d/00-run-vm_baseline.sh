#!/bin/bash
pip install ansible
git clone https://github.com/stfc/cloud-image-builders.git
cd cloud-image-builders
ansible-playbook os_builders/prepare_user_image.yml --extra-vars provision_this_machine=true -i os_builders/inventory/localhost.yml