# Image Building

## Contents:

- [Pipeline](#pipeline)
- [Setting Up the Environment](#setting-up-the-environment)
- [Building Images for Release](#building-images-for-release)
- [Testing Changes to Images (Troubleshoot or Bug Fixing)](#testing-changes-to-images-troubleshoot-or-bug-fixing)
- [Project Layout](#project-layout)

## Pipeline

The pipeline consists of the following steps:

- Packer pulls the latest generic image from the OS mirror into OpenStack
- Packer generates a SSH key and uploads it to OpenStack
- The VM is booted with the public key and uses the app creds user
- Ansible is run to configure the VM using the [prep_user_image](prep_user_image.yml) playbook
- Packer snapshots the VM and deletes the VM, SSH key and generic image

## Setting up the environment

1. Install pip, Ansible, Packer and OpenStack CLI
  ```shell
  # Ubuntu
  sudo apt install python3-pip python3-venv -y

  # Rocky
  sudo dnf install python3-pip python3-venv -y

  python3 -m venv image_builders
  source image_builder/bin/activate
  pip install -r requirements.txt

  ansible-playbook prep_builder.yml
  ```
2. Create an applications credential (admin is only required to make images public)
  ```shell
  # Either place app creds in directory

  mkdir -p ~/.config/openstack
  mv clouds.yaml ~/.config/openstack/clouds.yaml

  # Or

  # Export credentials
  export OS_AUTH_URL=https://<openstack_url>:5000/v3
  export OS_APPLICATION_CREDENTIAL_ID=<app_cred_id>
  export OS_APPLICATION_CREDENTIAL_SECRET=<app_cred_secret>
  ```
3. Git clone repository
  ```shell
  git clone https://github.com/stfc/cloud-image-builders.git
  cd cloud-image-builders/os_builders
  ```

## Building Images for Release

1. Activate virtual environment if not already
  ```shell
  source image_builder/bin/activate  # As made in the set up steps
  ```

2. Edit OpenStack External Network ID
  ```shell
  # Contents of: build.pkr.hcl
  18 networks          = [""]  # OpenStack External Network ID
  ```
3. Run Packer
  ```shell
  packer build .
  # Or to build only certain images
  packer build -only openstack.<builder-name>,openstack.<builder-name> .
  ```
4. Rename the current images to warehoused and new images to current name
  ```shell
  # REQUIRES ADMIN
  # For each image you are releasing
  current_image_name="<current-image-name>"
  new_image_id="<new-image-name>"
  timestamp=$(date +%F)
  openstack image set --deactivate --name "warehoused-${current_image_name}-${timestamp}" $current_image_name
  openstack image set --public --name "${current_image_name}" $new_image_id

  # For example, this may look like the below
  current_image_name="ubuntu-noble-24.04-nogui"
  new_image_id="ubuntu-noble-24.04-nogui-2025-11-20-abcde"
  timestamp=$(date +%F)
  openstack image set --deactivate --name "warehoused-${current_image_name}-${timestamp}" $current_image_name
  openstack image set --public --name "${current_image_name}" $new_image_id

  # ubuntu-noble-24.04-nogui is:
  #  - deactivated
  #  - renamed to warehoused-ubuntu-noble-24.04-nogui-2025-22-20
  # ubuntu-noble-24.04-nogui-2025-11-20-abcde is:
  #  - set to public
  #  - renamed to ubuntu-noble-24.04-nogui
  ```

## Testing Changes to Images (Troubleshoot or Bug Fixing)

1. Activate virtual environment if not already
  ```shell
  source image_builder/bin/activate  # As made in the set up steps
  ```
2. Generate a temporary SSH key to use on the VMs and add to OpenStack
  ```shell
  passphrase=$(pwgen 10 1)
  fed_id=<fed-id>
  ssh-keygen -t rsa -f image_testing_key -N $passphrase
  openstack keypair create --public-key=./image_testing_key.pub "image-testing-key-${fed_id}"
  ```
3. Create a VM using the current latest image for the OS you are fixing
  ```shell
  openstack server create <server-name> --image <os-image> --key-name "image-testing-key-${fed_id}" \
  --flavor l3.nano --network Internal  --wait
  ```
4. Edit `inventory.yml` and add your hosts IP
  ```shell
  # Get IP of VM
  openstack server show <server-name> -f json | jq .addresses.Internal | jq first

  # Contents of: inventory.yml
  5 ansible_host: "172.16.255.255"  # Your hosts IP
  ```
5. Run the baseline against the VM
  ```shell
  ansible-playbook -i inventory vm_baseline.yml
  ```
6. Run any other custom playbooks against the VM which you want to test
  ```shell
  ansible-playbook -i inventory <other-playbook.yml>
  ```

7. Repeat step 5/6 making changes to the playbooks and commit and PR any changes that are working.

## Project Layout
```shell
os_builders
├── README.md
├── build.pkr.hcl  # Packer build file
├── galaxy.yml  # Ansible Galaxy collection metadata
├── prep_builder.yml  # Playbook to install Packer
├── prepare_user_image.yml  # Playbook to configure the images
├── requirements.txt  # Specifies Ansible version
└── roles  # Roles to configure the image
    ├── container_registry/
    ├── nubes_bootcontext/
    ├── prep_builder/
    ├── tidy_image/
    └── vm_baseline/
```
