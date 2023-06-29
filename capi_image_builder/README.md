Prerequisites
=============

- Valid SSH Key:

On a worker machine generate a new SSH key, this cannot have a password
Go to https://github.com/stfc/k8s-image-builder, Settings → Deploy Keys and add the public key
Ensure Push Access is enabled

- clouds.yaml using Application Credentials that can push the image to a given project 

Setup
=====

- cd SCD-OpenStack-Utils/capi_image_builder && python3 -m venv venv
- source venv/bin/activate
- python3 -m pip install -r requirements.txt


Usage
=====

python3 main ~/.ssh/id_rsa --openstack-cloud openstack

Additional arguments are available by simply running `python3 main.py --help`, these include making images public, or rebasing the forked repo.