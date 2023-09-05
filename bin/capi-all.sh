#!/usr/bin/env bash
set -euxo pipefail

# Get root of repo based on the location of this script
REPO_ROOT="$(dirname "$(dirname "$(readlink -fm "$0")")")"

# Inject the custom roles
CUSTOM_ROLE_PATH="${REPO_ROOT}/cluster-api/ansible_stfc_roles.json"

# Build each version of the image
shopt -s nullglob  # This forces bash to expand the glob 
VERSIONS=( "${REPO_ROOT}"/cluster-api/versions/*.json )

for version_path in "${VERSIONS[@]}"; do
    echo "Building image for version: ${version_path}..."
    export PACKER_VAR_FILES="${CUSTOM_ROLE_PATH} ${version_path}"
    make -C "${REPO_ROOT}/k8s-image-builder/images/capi" build-qemu-ubuntu-2004
done