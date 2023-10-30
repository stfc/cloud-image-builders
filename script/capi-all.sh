#!/usr/bin/env bash
set -euxo pipefail

PARALLEL_JOBS=1

while getopts hj: opt; do
    case ${opt} in
        h)
            echo "Usage: $0 [-h]"
            echo "  -h    Display this help message."
            echo "  -j    Number of parallel jobs to run, default: 1"
            exit 0
            ;;
        j)
            PARALLEL_JOBS="${OPTARG}"
            ;;
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# Get root of repo based on the location of this script
REPO_ROOT="$(dirname "$(dirname "$(readlink -fm "$0")")")"

# Inject the custom roles
CUSTOM_ROLE_PATH="${REPO_ROOT}/cluster-api/ansible_stfc_roles.json"

# Build each version of the image
shopt -s nullglob  # This forces bash to expand the glob 
VERSIONS=( "${REPO_ROOT}"/cluster-api/versions/*.json )

for version_path in "${VERSIONS[@]}"; do
    (
    echo "Building image for version: ${version_path}..."
    export PACKER_VAR_FILES="${CUSTOM_ROLE_PATH} ${version_path}"
    make -C "${REPO_ROOT}/k8s-image-builder/images/capi" build-qemu-ubuntu-2004
    ) &
    
    # https://unix.stackexchange.com/a/436713
    # allow to execute up to $N jobs in parallel
    if [[ $(jobs -r -p | wc -l) -ge $PARALLEL_JOBS ]]; then
        # now there are $N jobs already running, so wait here for any job
        # to be finished so there is a place to start next one.
        wait -n
    fi
done
