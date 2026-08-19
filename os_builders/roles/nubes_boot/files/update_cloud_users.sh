#!/bin/bash

set -euxo pipefail

mkdir -p /mnt/context
if [[ ! -d "/mnt/context/openstack" ]]; then
    mount /dev/sr0 /mnt/context
fi

INSTANCEID=$(jq -r .uuid /mnt/context/openstack/latest/meta_data.json)

BASE_URLS=(
    "https://openstack.stfc.ac.uk"
    "https://dev-openstack.stfc.ac.uk"
)


OPENSTACK_URL=""
for base in  "${BASE_URLS[@]}"; do
    url="${base}:9999/getusername?serverID=${INSTANCEID}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [[ $HTTP_CODE = 200 ]]; then
        OPENSTACK_URL="$url"
        break
    else
        echo "Error Connecting to ${OPENSTACK_URL}: Expected 200 got ${HTTP_CODE}, trying another"
    fi
done

if [[ -z "$OPENSTACK_URL" ]]; then
    echo "Failed to get valid OpenStack endpoint"
    exit 1
fi


# --- Fetch FEDID with retries ---
FEDID=""
for _ in {1..3}; do
    FEDID=$(curl -fs "$OPENSTACK_URL" || true)

    if [[ -n "$FEDID" ]]; then
        break
    fi
    sleep 1
done

if [[ -z "$FEDID" ]]; then
    echo "Failed to retrieve FEDID from ${OPENSTACK_URL}"
    exit 1
fi

SSH_PUBLIC_KEY=$(jq -r .keys[0].data /mnt/context/openstack/latest/meta_data.json)

getent group wheel > /dev/null || groupadd wheel

id -u "$FEDID" || useradd "$FEDID" -g wheel -m -s /bin/bash
usermod "$FEDID" -a -G wheel,cloud

[[ -d /home/"$FEDID"/.ssh ]] || mkdir -p /home/"$FEDID"/.ssh
chown "$FEDID" /home/"$FEDID"
chown "$FEDID" /home/"$FEDID"/.ssh
if [[ "$FEDID" == "$FEDID" ]]; then
    if ! grep -qF "${SSH_PUBLIC_KEY//\\n/}" /home/"$FEDID"/.ssh/authorized_keys; then
        echo "${SSH_PUBLIC_KEY//\\n/}" >> /home/"$FEDID"/.ssh/authorized_keys
    fi
fi
chown "$FEDID" /home/"$FEDID"/.ssh/authorized_keys
