#!/bin/bash

echo -n "$(jq -r .workspaceId /usr/local/gitpod/config/spec.json).gitpod.local"
