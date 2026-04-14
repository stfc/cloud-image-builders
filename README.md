# cloud-image-builders
Builders for all our Cloud images. Each builder has it's own README.md which contains the technical doccumentation on set up and usage.

## Contents

- [amphora-image-builder](#amphora-image-builder)
- [cluster-api](#cluster-api)
- [os_builders](#os_builders) 
- [Non-Build Directories](#non-build-directories)

## amphora-image-builder

The [amphora-image-builder](amphora-image-builder) is a container used to build an image used by the OpenStack Octavia VMs called Amphora.

## cluster-api

The [cluster-api](cluster-api) directory contains configuration to extend the upstream Kubernetes image builder.It includes references to our [os_builder](os_builder/roles) roles. This ensures our CAPI images contain the VM baseline we apply to all images such as security policy.

## os_builders

The [os_builders](os_builders) directory contains our bespoke image building pipeline utilising Packer and Ansible to remotely build images for OpenStack virtual machines. This is where we build all Ubuntu and Rocky images used on the Cloud.

## Non-Build Directories

- [scripts](scripts) - A directory containing helper scripts to make building and testing easier when performed manually.

- [k8s-image-builder](k8s-image-builder) - A git submodule containing the upstream Kubernetes image builder.
