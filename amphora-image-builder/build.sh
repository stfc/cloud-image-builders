#!/bin/bash

set -e

docker build . -t amphora-image-builder:local

# The Amphora builder requires privileged access to the host
# to mount /proc and /sys
docker run --privileged -v "$(pwd)":/output amphora-image-builder:local
