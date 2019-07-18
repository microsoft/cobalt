#!/usr/bin/env bash

set -euo pipefail

echo "Checking out test harness"

CHECKOUT_DIR="./test-harness-repo-local-checkout/"
rm -rf "$CHECKOUT_DIR"

git clone --depth 1 "$TEST_HARNESS_REPOSITORY_GIT_URL" "$CHECKOUT_DIR"
mv "$CHECKOUT_DIR/$TEST_HARNESS_DIR/" .
mv "$CHECKOUT_DIR"/go.* .

rm -rf "$CHECKOUT_DIR"
echo "Finished checking out test harness"
