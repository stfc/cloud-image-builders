# cluster-api

This project contains the current versions of Kubernetes that the Cloud Group will support and builds images for.

## Setup

1. Install Ansible and any other pip requirements:
   ```shell
   sudo apt-get install python3-venv unzip -y
   # or
   sudo dnf install python3-venv unzip -y

   python3 -m venv venv
   source venv/bin/activate
   pip install -r os_builders/requirements.txt
   ```

2. Install Packer and dependencies:
   ```shell
   cd os_builders
   # If sudo is passwordless:
   ansible-playbook prep_builder.yml
   # If password is required for sudo:
   ansible-playbook prep_builder.yml --ask-become-pass
   ```

3. Update the date in the [common_vars.json](./common_vars.json#L12) file for `image_name`

## Rate Limiting

You may run into GitHub rate limiting issues when building images. To avoid this, you can set the following environment variable:

`PACKER_GITHUB_API_TOKEN=<token>`

The token can be generated from your GitHub settings, under developer access, and only needs the `public_repo` scope (i.e. the default).

## OpenStack authentication

You need to set up credentials for OpenStack authentication as we are using a remote builder. Create a clouds.yaml application credential and place it into `~/.config/openstack/clouds.yaml`. See [here](https://stfc.atlassian.net/wiki/spaces/CLOUDKB/pages/211484774/Application+Credentials) for help.

Addtionally, you will need to specify the cloud name in your session by exporting it. By default this will be `openstack` as seen in the standard `clouds.yaml` file:

`export OS_CLOUD=<cloud-name>`

## Build a specific version

1. Grab the latest version of the K8s Image Builder submodule:
   ```shell
   cd ..  # back to repo root
   git submodule update --init --recursive --remote
   ```
2. Set up variable paths
   ```shell
   # Point to our custom roles:
   export ANSIBLE_ROLES_PATH="$(pwd)/os_builders/roles:$(pwd)/cluster-api/roles"
   # Choose K8s version from "versions" directory
   export K8S_VERSION="cluster-api/versions/v1_33.json"
   # Choose which environment to build in
   export PACKER_BUILD_ENV="<dev-or-prod>"
   # Tell Packer where the vars files are
   export PACKER_VAR_FILES="$(pwd)/${K8S_VERSION} $(pwd)/cluster-api/${PACKER_BUILD_ENV}_vars.json $(pwd)/cluster-api/common_vars.json"
   ```
3. Build the image
   ```shell
   # Run build
   make -C k8s-image-builder/images/capi build-openstack-ubuntu-2204
   # It will be released with the following properties:
   #    - name: capi-ubuntu-22.04-kube-<k8s-version>-<todays-date>
   #    - visibility: private
   ```
4. Follow steps for release [here](#update-an-image-for-release)

## Adding a new version
1. Update the image builder:
   ```shell
   cd ..  # back to repo root
   git submodule update --init --recursive --remote
   ```
2. Add new version file:
    1. Navigate to https://kubernetes.io/releases/
    2. Find the version you want to add or update
    3. Create/Update the semver in the relevant JSON file. There should be a 1:1 mapping of JSON files to major versions of Kubernetes. E.g. a file for 1.24, 1.25, etc.
3. Follow steps to build a specific version [here](#build-a-specific-version)
4. Follow steps for release [here](#update-an-image-for-release)

## Rebuild all images
1. Update the image builder:
   ```shell
   cd ..  # back to repo root
   git submodule update --init --recursive --remote
   ```
2. Update patch versions in version files
   ```
   # Contents of ./versions/v1_33.json
   {
       "kubernetes_series": "v1.33",
       "kubernetes_semver": "v1.33.3", -> "v1.33.4"
       "kubernetes_deb_version": "1.33.3-1.1" -> "v1.33.4-1.1"
   }
   ```
3. Run build-all.sh
   ```shell
   cd scripts
   ./build-all.sh <env>  # dev or prod
   ```
4. Follow steps for release for each image [Update and image for release](#update-an-image-for-release)

## Update an image for release
1. Check the image you are working with before you make any changes
   ```shell
   openstack image show <image-name>
   ```
2. Build a cluster with the new image [here](https://stfc.atlassian.net/wiki/spaces/CLOUDKB/pages/211878034/Cluster+API+Setup) and check it builds successfully
3. Set image to public
   ```shell
   openstack image set --public <image-name>
   ```

### Developer Notes
Since we cannot add comments to JSON files I've documented some points here:

- Currently we need to manually update minor versions of Kubernetes. We need to investigate how to update this long-term.
- We need to maintain multiple images in the past, as an upgrade can only do n+1 versions at a time.
- There's no check that git-submodules are up to date, so we need to manually update them.
- Image properties are inherited from the base image, in this case `ubuntu-jammy-22.04-nogui`, so they will always be correct if we assume that image is true
