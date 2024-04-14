#!/bin/bash

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

#echo -n "$(jq -r .workspaceId /usr/local/gitpod/config/spec.json).gitpod.local"
default_interface=$(ip route show default | awk '/default/ {print $5}')
default_ip=$(ip addr show $default_interface | awk '/inet / {print $2}' | cut -d/ -f1)

echo "WORKSPACE_ID=$default_ip.nip.io" > "${CURRENT_DIR}/container.env"

#cat /usr/local/gitpod/shared/kubeconfig.yaml > "${CURRENT_DIR}/kubeconfig.yaml"
