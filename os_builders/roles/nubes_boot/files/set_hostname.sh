#!/bin/bash

set -euxo pipefail

ipaddress=$(hostname -I | sed -e "s/ //g" -e "s/\./-/g")
FQDN="host-${ipaddress}-nubes.stfc.ac.uk"

hostnamectl set-hostname "${FQDN}";
