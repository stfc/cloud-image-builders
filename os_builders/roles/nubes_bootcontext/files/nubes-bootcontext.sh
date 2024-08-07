#!/bin/bash

hostname="networktest"

while [[ $hostname == "networktest" ]];
do
    sleep 5s
    ipaddress=$(hostname -I)
    #ipaddress=`ip addr show eth0  | grep inet | grep -v inet6 | cut -d " " -f6 | cut -d "/" -f1`
    if [[ $ipaddress == "130."* ]]; then
        hostname=`dig -x $ipaddress +short | sed "s/.ac.uk./.ac.uk/g"`;
        if [ `echo $hostname | grep "ac"` ]; then
            hostname $hostname;
        else
            hostname="networktest";
        fi;

    fi;
done;

##Fixing the SSHD config to allow for AD password logins

if ! cat /etc/ssh/sshd_config | grep Kerberos | grep -qv '^#'; then
    echo "KerberosAuthentication yes\nKerberosOrLocalPasswd yes\nKerberosTicketCleanup yes\nKerberosGetAFSToken no" >> /etc/ssh/sshd_config
fi

##Adding Kerberos auth to the pam common auth module which will add AD auth to console logins

if ! grep -q pam_krb5.so /etc/pam.d/common-auth; then
    sed -i "/nullok_secure/iauth    \[success=2 default=ignore\]      pam_krb5.so minimum_uid=1000" /etc/pam.d/common-auth
fi

##Adjusting the minimum_uid value to stop the passwd command asking for the current krb5 password

if grep -q minimum_uid=1000 /etc/pam.d/common-password; then
    sed -i "s/minimum_uid=1000/minimum_uid=10000/" /etc/pam.d/common-password
fi

/usr/local/sbin/update_cloud_users.sh
