#!/bin/bash

for i in packer packer-test;
do
    userdel $i -r;
done

mkdir /mnt/context
mount /dev/sr0 /mnt/context
INSTANCEID=$(jq .uuid /mnt/context/openstack/latest/meta_data.json | sed "s/\"//g")

if curl -s http://openstack.nubes.rl.ac.uk:9999/cgi-bin/get_username_list.sh?"$INSTANCEID" | grep ".";
then
    OPENSTACK_URL='openstack.nubes.rl.ac.uk'
else
    OPENSTACK_URL='dev-openstack.nubes.rl.ac.uk'
fi

echo $OPENSTACK_URL

FEDIDS=$(curl -s http://$OPENSTACK_URL:9999/cgi-bin/get_username_list.sh?"$INSTANCEID")
FEDID=$(curl -s http://$OPENSTACK_URL:9999/cgi-bin/get_username.sh?"$INSTANCEID")

while [ -z "$FEDID" ]
   do
    if [ -z "$INSTANCEID" ]
    then
        INSTANCEID=$(dmidecode | grep UUID | tr '[:upper:]' '[:lower:]' | sed "s/\\tuuid: //")
    fi
    FEDID=$(curl -s http://$OPENSTACK_URL:9999/cgi-bin/get_username.sh?"$INSTANCEID")
    ((c++)) && ((c==3)) && c=0 && break
   done

SSH_PUBLIC_KEY=$(jq .keys[0].data /mnt/context/openstack/latest/meta_data.json | sed "s/\"//g")

groupadd wheel

for ID in $FEDIDS; do
    useradd "$ID" -g wheel -m -s /bin/bash
    usermod "$ID" -a -G wheel
    SUDOVALID=$(visudo -c -f /etc/sudoers.d/cloud)
    if [ "$SUDOVALID" != "/etc/sudoers.d/cloud: parsed OK" ]
    then
        echo " $ID  ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/cloud
    fi
    if grep -q "$ID" /etc/sudoers.d/cloud
    then
        true
    else
        echo " $ID  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/cloud
    fi
    chmod 0440 /etc/sudoers.d/cloud
    mkdir -p /home/"$ID"/.ssh
    chown "$ID" /home/"$ID"
    chown "$ID" /home/"$ID"/.ssh
    if [[ "$ID" == "$FEDID" ]]; then
        echo "$SSH_PUBLIC_KEY "| sed 's/\\n//g' >> /home/"$ID"/.ssh/authorized_keys
    fi
    chown "$ID" /home/"$FEDID"/.ssh/authorized_keys
done
