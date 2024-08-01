#!/bin/bash

set -euxo pipefail

cd /tmp
python3 -m virtualenv octavia_disk_image_create
# shellcheck source=/dev/null
source octavia_disk_image_create/bin/activate

git clone --depth=1 https://github.com/openstack/octavia
DIB_REPO_PATH="$(pwd)/octavia"
export DIB_REPO_PATH

cd octavia/diskimage-create
pip3 install -r requirements.txt
./diskimage-create.sh -t raw -o "/output/amphora-x64-$(date +"%Y-%m-%d")-haproxy.raw"
