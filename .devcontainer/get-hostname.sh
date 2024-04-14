#!/bin/bash

#echo -n "$(jq -r .workspaceId /usr/local/gitpod/config/spec.json).gitpod.local"
default_interface=$(ip route show default | awk '/default/ {print $5}')
default_ip=$(ip addr show $default_interface | awk '/inet / {print $2}' | cut -d/ -f1)
echo -n "$default_ip.nip.io"
