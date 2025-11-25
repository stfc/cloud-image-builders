#!/bin/bash

current_image_name=$1
new_image_id=$2
timestamp=$(date +%F)
openstack image set --deactivate --name "warehoused-${current_image_name}-${timestamp}" $current_image_name
openstack image set --public --name "${current_image_name}" $new_image_id
