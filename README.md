# cloud-image-builders
Builders for various cloud images. Each folder has a README
which walks through the process of setting up and building the image.

Handy Documentation
===================

The following documentation is useful for all builders:

- [Uploading an image to OpenStack](https://docs.openstack.org/python-openstackclient/latest/cli/command-objects/image-v1.html#image-create)


Contents
========

amphora-image-builder
---------------------

This is a container to build an amphora image for use with OpenStack Octavia.

cluster-api
-----------

This directory contains customisations to extend the upstream Kubernetes image builder
to include custom STFC roles. It uses the roles found in the `os_builders` directory
to share common roles between the two (e.g. security policy, etc.), and also includes
some CAPI specific customisations such as a pull-through cache.

os_builders
-----------

A directory containing all publicly available generic images (excluding Cluster API)
which share common packer build roles

Non-Build Directories
=====================

- script

Contains various helper scripts to make building and testing easier when performed manually.

- K8s Image Builder

A git submodule containing the upstream Kubernetes image builder.
