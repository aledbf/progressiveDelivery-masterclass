#!/bin/bash

echo "post-start start" >> ~/status

# this runs in background each time the container starts

# update the base docker images
#docker pull mcr.microsoft.com/dotnet/sdk:5.0-alpine
#docker pull mcr.microsoft.com/dotnet/aspnet:5.0-alpine
#docker pull mcr.microsoft.com/dotnet/sdk:5.0

source /workspaces/progressiveDelivery-masterclass/.devcontainer
mkdir -p ~/.kube
echo "${KUBECONFIG_CONTENT}" > ~/.kube/config
export KUBECONFIG=~/.kube/config

echo "post-start complete" >> ~/status