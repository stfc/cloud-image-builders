#!/bin/bash

set -xeuo pipefail

hostname="networktest"

while [[ "$hostname" == "networktest" ]];
do
    
    ipaddress=$(hostname -I | sed "s/ //g")

    if [[ "$ipaddress" == "130."* ]] || [[ $ipaddress == "172."*  ]]; then
        hostname=$(dig -x "$ipaddress" +short | sed "s/.ac.uk./.ac.uk/g");
        if echo "$hostname" | grep -q "ac"; then
            hostname "$hostname";
        else
            hostname="networktest";
        fi;
        sleep 5s
        ((c++)) && ((c==3)) && c=0 && break


    else
        break;
    fi;

done;

/usr/local/sbin/update_cloud_users.sh
/usr/local/sbin/update_keys.sh

systemctl restart wazuh-agent
