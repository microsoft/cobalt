#!/usr/bin/env bash
set -euo pipefail

# Check if `jq` is installed. If not, fail fast.
command -v jq >/dev/null 2>&1 || { echo >&2 "jq is not installed. Please re-run after installing"; exit 1; }

# This command queries for the subnets in a VNET
# and emits them in the following format:
#   [
#       { name: <subnet name 1>, id: <subnet ID 1> },
#       { name: <subnet name 2>, id: <subnet ID 2> },
#       ...
#   ]
SUBNET_LISTING=$(az network vnet subnet list \
    --subscription $1       \
    --resource-group $2     \
    --vnet-name $3          \
    --output json           \
    --query "[*].{id:id,name:name}")

# This command transforms the output from the above command
# into a format that can be understood by the terraform external
# data source, which is `map[string]string`. Here is some
# documentation about this data source:
#   https://www.terraform.io/docs/providers/external/data_source.html
#
# The transformed data looks like this:
#   {
#       <subnet name 1>: <subnet ID 1>,
#       <subnet name 2>: <subnet ID 2>,
#       ...
#   }
# Which matches the schema needed by terraform.
echo $SUBNET_LISTING | jq 'reduce .[] as $i ({}; .[$i.name] = $i.id)'
