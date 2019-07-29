#!/usr/bin/env bash

set -euo pipefail

mv "$INFRASTRUCTURE_DIR"/templates/$(ls "$INFRASTRUCTURE_DIR"/templates/) "$INFRASTRUCTURE_DIR"/templates/tf-template
