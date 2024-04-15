#!/bin/bash

CURRENT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)

#echo -n "$(jq -r .workspaceId /usr/local/gitpod/config/spec.json).gitpod.local"
default_interface=$(ip route show default | awk '/default/ {print $5}')
default_ip=$(ip addr show "$default_interface" | awk '/inet / {print $2}' | cut -d/ -f1)

export INGRESS_HOST=$(printf "%s.nip.io" "$default_ip")

echo "INGRESS_HOST=${INGRESS_HOST}" > "${CURRENT_DIR}/container.env"

echo "Waiting for the kind cluster to be ready..."
export KUBECONFIG="/usr/local/gitpod/shared/kubeconfig.yaml"
while [ ! -f "${KUBECONFIG}" ]; do
  sleep 5
done

while :; do
  ready_nodes=$(kubectl get nodes --no-headers | grep -c "Ready")

  if [ "$ready_nodes" -eq "$(kubectl get nodes --no-headers | wc -l)" ]; then
    echo "All nodes in the cluster are ready."
    break
  fi

  sleep 5
done

#cp /usr/local/gitpod/shared/kubeconfig.yaml "${CURRENT_DIR}/kubeconfig.yaml"

# create the argocd namespace
kubectl create namespace argocd

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: ingress-hostnames
  namespace: argocd
  labels:
    app.kubernetes.io/part-of: argocd
data:
  argocd: "argocd.${INGRESS_HOST}"
  grafana: "grafana.${INGRESS_HOST}"
  demoapp: "${INGRESS_HOST}"
  jaeger: "jaeger.${INGRESS_HOST}"  
  prometheus: "prometheus.${INGRESS_HOST}"
EOF
