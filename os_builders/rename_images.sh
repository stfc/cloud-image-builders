#!/bin/bash

set -xeo pipefail

image_name=$1
new_image_id=$2
timestamp=$(date +%F)
warehoused_image_id=$(openstack image show "$image_name" -f value -c "ID")
warehoused_image_name="warehoused-${image_name}-${timestamp}"


if [[ "$image_name" == *aq ]]; then
    openstack image set --shared "$new_image_id"
    for MEMBER in $(openstack image member list -f value -c "Member ID" "$warehoused_image_id"); do
        openstack image add project "$new_image_id" "$MEMBER";
        openstack image set --accept --project "$MEMBER" "$new_image_id";
    done
   
else
    openstack image set --public --name "$image_name" "$new_image_id"
fi

openstack image set --deactivate --name "$warehoused_image_name" "$warehoused_image_id"

cat << EOF
Please make an Elog entry to record this change:

Rebuild of OS image $image_name. Built with image builder version $(cat version.txt | tr -d '\n')

Last -> New

$warehoused_image_id -> $new_image_id
EOF
