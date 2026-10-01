#!/bin/bash
set -euxo pipefail

CURRENT_DIR=$(dirname "$0")

python3 -m venv /tmp/packer-default-venv
# shellcheck source=/dev/null

source /tmp/packer-default-venv/bin/activate
pip3 install -r "${CURRENT_DIR}/requirements.txt"

export ANSIBLE_FORCE_COLOR=1
export PYTHONUNBUFFERED=1
exec /tmp/packer-default-venv/bin/ansible-playbook "$@"
