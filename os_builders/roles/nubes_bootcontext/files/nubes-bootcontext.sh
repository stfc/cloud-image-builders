#!/bin/bash

set -xeuo pipefail


/usr/local/sbin/set_hostname.sh
/usr/local/sbin/update_cloud_users.sh
/usr/local/sbin/update_keys.sh

systemctl restart wazuh-agent
