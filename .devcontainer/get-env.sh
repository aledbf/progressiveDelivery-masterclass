#!/bin/bash

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

#echo -n "$(jq -r .workspaceId /usr/local/gitpod/config/spec.json).gitpod.local"
default_interface=$(ip route show default | awk '/default/ {print $5}')
default_ip=$(ip addr show "$default_interface" | awk '/inet / {print $2}' | cut -d/ -f1)

echo "ENCODED_WORKSPACE_ID=$(printf "%s.nip.io" "$default_ip" | base64 -w0)" > "${CURRENT_DIR}/container.env"

echo "Waiting for the kind cluster to be ready..."
export KUBECONFIG=/usr/local/gitpod/shared/kubeconfig.yaml

while :; do
  ready_nodes=$(kubectl get nodes --no-headers | grep -c "Ready")

  if [ "$ready_nodes" -eq "$(kubectl get nodes --no-headers | wc -l)" ]; then
    echo "All nodes in the cluster are ready."
    break
  fi

  sleep 5
done

cat /usr/local/gitpod/shared/kubeconfig.yaml > "${CURRENT_DIR}/kubeconfig.yaml"
