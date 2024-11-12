#!/bin/bash

set -euxo pipefail

DIB_RELEASE="jammy"  # Ubuntu 22.04
export DIB_RELEASE

cd /tmp
python3 -m virtualenv octavia_disk_image_create
# shellcheck source=/dev/null
source octavia_disk_image_create/bin/activate

git clone --depth=1 https://opendev.org/openstack/octavia
DIB_REPO_PATH="$(pwd)/octavia"
export DIB_REPO_PATH

# run local config elements
cd /opt/cloud-image-builders
chmod 755 amphora-image-builder/elements/vm_baseline/*/*

cd /tmp
DIB_LOCAL_ELEMENTS="vm_baseline"
export DIB_LOCAL_ELEMENTS

DIB_LOCAL_ELEMENTS_PATH="/opt/cloud-image-builders/amphora-image-builder/elements"
export DIB_LOCAL_ELEMENTS_PATH

cd octavia/diskimage-create
pip3 install -r requirements.txt
./diskimage-create.sh -t qcow2 -m -o "/output/amphora-x64-$(date +"%Y-%m-%d")-haproxy.qcow2"
