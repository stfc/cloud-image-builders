#!/bin/bash

if ls /home/cloud
then
    KEYSPATH=/home/cloud
else
    KEYSPATH=/root
fi

if lsattr $KEYSPATH/.ssh/authorized_keys | grep "\-i\-"
then
    echo "file $KEYSPATH/.ssh/authorized_keys is immutable, cannot write admin key list to it. Generated from \`update_keys.sh\`." #| mail -s "Error during VM authorized_keys update" cloud-support@stfc.ac.uk
else
    wget http://openstack.nubes.rl.ac.uk:9999/admin_key_list
    if [ -f admin_key_list ]
    then
        mv admin_key_list $KEYSPATH/.ssh/authorized_keys
        if [ ! -s $KEYSPATH/.ssh/authorized_keys ]
        then
            echo "file $KEYSPATH/.ssh/admin_key_list is empty. The download from service node failed. Generated from \`update_keys.sh\`." #| mail -s "Error during VM authorized_keys update" cloud-support@stfc.ac.uk
        else
            grep "Alexander Dibbo" $KEYSPATH/.ssh/authorized_keys || { echo "file $KEYSPATH/.ssh/admin_key_list does not contain the correct keys. Generated from \`update_keys.sh\`."; } #| mail -s "Error during VM authorized_keys update" cloud-support@stfc.ac.uk ; }
        fi
    else
        echo "file $KEYSPATH/.ssh/admin_key_list does not exist. The download from service node failed. Generated from \`update_keys.sh\`." #| mail -s "Error during VM authorized_keys update" cloud-support@stfc.ac.uk
    fi
fi
