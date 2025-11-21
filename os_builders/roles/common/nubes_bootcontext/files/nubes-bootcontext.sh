#!/bin/bash

hostname="networktest"

while [[ "$hostname" == "networktest" ]];
do
    sleep 5s
    ipaddress=$(hostname -I | sed "s/ //g")

    if [[ "$ipaddress" == "130."* ]] || [[ $ipaddress == "172."*  ]]; then
        hostname=$(dig -x "$ipaddress" +short | sed "s/.ac.uk./.ac.uk/g");
        if echo "$hostname" | grep -q "ac"; then
            hostname "$hostname";
        else
            hostname="networktest";
        fi;

    fi;
done;

/usr/local/sbin/update_cloud_users.sh

systemctl restart wazuh-agent
