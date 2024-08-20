#!/usr/bin/python3

import os
import subprocess
import socket
import json

source = "/var/ossec/etc/ossec.template"
destination = "/var/ossec/etc/ossec.conf"

# Open template config file
with open(source) as sourcefile:
    ossec_string = sourcefile.read()

LABELS_STRING=""
AGENT_HOSTNAME=socket.getfqdn()

# Check if the host is an OpenStack VM
if os.path.exists("/mnt/context/openstack"):
    print("Is OpenStack")
    # Get metadata from openstack config drive
    with open("/mnt/context/openstack/latest/meta_data.json") as openstack_metadata_json:
        openstack_metadata = json.load(openstack_metadata_json)
    # Format Labels as XML
    LABELS_STRING = "{0}<label key=\"{1}\">{2}</label>".format(LABELS_STRING, "openstack.uuid", openstack_metadata["uuid"])
    LABELS_STRING = "{0}<label key=\"{1}\">{2}</label>".format(LABELS_STRING, "openstack.name", openstack_metadata["name"])
    LABELS_STRING = "{0}<label key=\"{1}\">{2}</label>".format(LABELS_STRING, "openstack.hostname", openstack_metadata["hostname"])
    LABELS_STRING = "{0}<label key=\"{1}\">{2}</label>".format(LABELS_STRING, "openstack.project_id", openstack_metadata["project_id"])
    AGENT_HOSTNAME = AGENT_HOSTNAME + "-" + openstack_metadata["uuid"]


if os.path.exists("/etc/ccm.conf"):
    print("Is Quattor Managed")
    # Get aquilon personality from profile
    p = subprocess.Popen(["/usr/sbin/ccm", "/system/personality/name"], bufsize=1, stdout=subprocess.PIPE)
    personality = p.communicate()
    # Remove cruft from string
    personality = str(personality[0]).replace('b"$ name : ', "").replace("'\\n\\n\"", '"').replace("'", '"')
    # Format as XML and merge into Labels XML - probably a better way of doing this but hayho
    LABELS_STRING = "{0}<label key=\"{1}\">{2}</label>".format(LABELS_STRING, "aq.personality", personality)

# Merge generated XML and hostname into config
ossec_string = ossec_string.replace("AGENT_HOSTNAME", AGENT_HOSTNAME)
ossec_string = ossec_string.replace("LABELS_LIST", LABELS_STRING)

#print(ossec_string)

# Write config out
with open(destination, 'w') as dest:
    dest.write(ossec_string)
