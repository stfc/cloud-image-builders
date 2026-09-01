# cluster-api

This project contains the current versions of Kubernetes that the Cloud Group will support and builds images for.


## Contents:

- [Setup](#setup)





## Setup

1. Clone this repository.
   ```shell
   git clone https://github.com/stfc/cloud-image-builders.git
   cd cloud-image-builders/cluster-api
   ```

2. Install Python requirements.
   ```shell
   sudo apt-get install python3-venv unzip -y
   # or
   sudo dnf install python3-venv unzip -y

   # Then
   python3 -m venv venv
   source venv/bin/activate
   pip install -r ../os_builders/requirements.txt
   ```

2. Install Packer and dependencies:
   ```shell
   cd ../os_builders
   # If sudo is passwordless:
   ansible-playbook prep_builder.yml
   # If password is required for sudo:
   ansible-playbook prep_builder.yml --ask-become-pass
   cd ../cluster-api
   ```
3. Set up OpenStack authentication. Get a clouds.yaml for the **packer** project. See [here](https://stfc.atlassian.net/wiki/spaces/CLOUDKB/pages/211484774/Application+Credentials)
   ```shell
   # Copy clouds.yaml to the config directory
   mkdir -p ~/.config/openstack
   cp <path-to-clouds.yaml> ~/.config/openstack/clouds.yaml

   # Export the cloud name in clouds.yaml, default is openstack
   export OS_CLOUD=openstack
   ```

### Rate Limiting (Optional)

You may run into GitHub rate limiting issues when building images. To avoid this, you can set the following environment variable:

`PACKER_GITHUB_API_TOKEN=<token>`

The token can be generated from your GitHub settings, under developer access, and only needs the `public_repo` scope (i.e. the default).

## Update the CAPI image versions

1. Clone the repository with write access, usually by SSH
   ```shell
   git clone git@github.com:stfc/cloud-image-builders.git
   cd cloud-image-builders/cluster-api
   ```

2. Create a new branch called update_k8s_versions
   ```shell
   git switch -c update_k8s_versions
   ```

3. Update the k8s submodule
   ```shell
   git submodule update --init --recursive --remote
   ```

4. Perform the following checks against the releases page [here](https://kubernetes.io/releases/).
   1. If there is a new version, add a new file in [versions](./versions). Use the other versions as a template. We don't release the latest version.
      ```shell
      cd versions
      cp v1_35.json v1_36.json

      # Update to the version number
      vim v1_36.json
      ```
   2. If [versions](./versions) contains more than 3 version files, delete the oldest so we have only 3.

5. Run update_capi_versions.sh and update each version file with the latest version.
   ```shell
   ./update_capi_versions.sh
   ...
   (venv) venv ❯ ./update_capi_versions.sh
   kubernetes_series    kubernetes_semver    kubernetes_deb_version   
   -------------------  -------------------  ------------------------ 
   v1.32                v1.32.13             1.32.13-1.1              
   v1.33                v1.33.13             1.33.13-1.1              
   v1.34                v1.34.11             1.34.11-1.1      
   ...

6. Commit these changes to the branch and make a pull request
   ```shell
   git add versions/ ../k8s-image-builder
   git commit 
   ...
   Commit message
   ...
   git push --set-upstream origin update_k8s_versions

## Build a CAPI image

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
   #    - name: capi-ubuntu-22.04-kube-<k8s-version>
   #    - visibility: private
   ```
4. Follow steps for release [here](#update-an-image-for-release)

## Update an image for release
1. Check the image you are working with before you make any changes
   ```shell
   openstack image show <image-id>
   ```
2. Build a cluster with the new image [here](https://stfc.atlassian.net/wiki/spaces/CLOUDKB/pages/211878034/Cluster+API+Setup) and check it builds successfully
3. Set image to public
   ```shell
   openstack image set --public <image-id>
   ```
4. If this is the last supported patch version append `-eol` to the end of the image name
   ```shell
   openstack image set --name capi-ubuntu-2204-kube-v1.33.4-eol <image-id>
   ```

### Developer Notes
Since we cannot add comments to JSON files I've documented some points here:

- Currently we need to manually update minor versions of Kubernetes. We need to investigate how to update this long-term.
- We need to maintain multiple images in the past, as an upgrade can only do n+1 versions at a time.
- There's no check that git-submodules are up to date, so we need to manually update them.
- Image properties are inherited from the base image, in this case `ubuntu-jammy-22.04-nogui`, so they will always be correct if we assume that image is true
