#!/bin/bash

set -euxo pipefail

cd /tmp
python3 -m virtualenv octavia_disk_image_create
# shellcheck source=/dev/null
source octavia_disk_image_create/bin/activate

git clone --depth=1 https://github.com/openstack/octavia
DIB_REPO_PATH="$(pwd)/octavia"
export DIB_REPO_PATH

# run local config elements
git clone https://github.com/apdibbo/cloud-image-builders.git
#git clone https://github.com/stfc/cloud-image-builders.git
cd /tmp/cloud-image-builders
git checkout origin/amphora-ral
ls /tmp
DIB_LOCAL_ELEMENTS="vm_baseline"
export DIB_LOCAL_ELEMENTS
DIB_LOCAL_ELEMENTS_PATH="/tmp/cloud-image-builders/amphora-image-builder/elements"
export DIB_LOCAL_ELEMENTS_PATH

cd octavia/diskimage-create
pip3 install -r requirements.txt
./diskimage-create.sh -t raw -o "/output/amphora-x64-$(date +"%Y-%m-%d")-haproxy.raw"
