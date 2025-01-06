#!/bin/bash

set -euo pipefail

# Move up a dir so we can include this git repo in the build
# so any changes to the elements can be tested
cd .. 
docker build -f amphora-image-builder/Dockerfile -t amphora-image-builder:local .

# The Amphora builder requires privileged access to the host
# to mount /proc and /sys
docker run --privileged -v "$(pwd)/output":/output amphora-image-builder:local
cd amphora-image-builder
