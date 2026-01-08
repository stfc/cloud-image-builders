#!/usr/bin/env bash
set -euxo pipefail
shift $((OPTIND-1))

# Enter dev or prod when running this script. I.e ./build-all.sh dev
env=$1
# Get root of repo based on the location of this script
REPO_ROOT="$(dirname "$(dirname "$(readlink -fm "$0")")")"

# Store the location to the custom roles which are shared from our OS builder...

CUSTOM_ROLE_PATH="${REPO_ROOT}/cluster-api/${env}_vars.json"

# Update the image name in vars file to include date
COMMON_VARS_PATH="${REPO_ROOT}/cluster-api/common_vars.json"
if grep -E "[0-9]{4}-[0-9]{2}-[0-9]{2}" "${COMMON_VARS_PATH}"; then
    sed -i -E "s/[0-9]{4}-[0-9]{2}-[0-9]{2}/$(date +%F)/" "${COMMON_VARS_PATH}"
else
    echo "Date not found in common_vars.json"
    exit 1
fi

# ... and make sure Ansible knows where to find on this machine
export ANSIBLE_ROLES_PATH="${REPO_ROOT}/os_builders/roles:${REPO_ROOT}/cluster-api/roles"

# Build each version of the image
shopt -s nullglob  # This forces bash to expand the glob 
VERSIONS=( "${REPO_ROOT}"/cluster-api/versions/*.json )

for version_path in "${VERSIONS[@]}"; do
    echo "Building image for version: ${version_path}..." && \
    export PACKER_VAR_FILES="${CUSTOM_ROLE_PATH} ${COMMON_VARS_PATH} ${version_path}" && \
    make -C "${REPO_ROOT}/k8s-image-builder/images/capi" build-openstack-ubuntu-2204 &
done
