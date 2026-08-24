#!/bin/bash

set -euxo pipefail

ipaddress=$(hostname -I | sed -e "s/ //g" -e "s/\./-/g")
if [[ $ipaddress == 192-168* ]] || [[ $ipaddress == 10-10* ]]; then
    # This is required so Pakiti can tell the difference between to VMs with the same IP.
    FQDN=$(jq .uuid /mnt/context/openstack/latest/meta_data.json)
else
    FQDN="host-${ipaddress}-nubes.stfc.ac.uk"
fi

hostnamectl set-hostname "${FQDN}";
