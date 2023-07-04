# cloud-image-builders
Builders for various cloud images. See each README for more information.

Contents
========

- Amphora image builder

This is a tool to build an amphora image for use with OpenStack Octavia.

- OS Builders

A directory containing all publicly available generic images (excluding Cluster API)
which share common packer build roles

- CAPI Image Builder

A directory containing a script for building and uploading CAPI images to
OpenStack. It also contains a submodule for upstream and customisations to build in
the changes from the OS Builders directory, and some K8s specific changes.