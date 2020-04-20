#!/usr/bin/env bash
# borrowed from https://github.com/matti/terraform-shell-resource/blob/master/read.sh

# This script expects a single argument, which is a file to read

set +e
FILE=$(cat $1 || echo "{}")
set -e
echo "$FILE"
