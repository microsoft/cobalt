# NAME: build-base-image.sh
# DESCRIPTION: 
# Builds the docker test harness base image. This image comes pre-installed with 
# Azure CLI, GO, Dep, GCC, git, unzip, wget, terraform
# This base image also pre-installs the golang vendor packages.
# -g : GOLang version 
# -t : Terraform version
# USAGE: ./test-harness/build-base-image.sh -g "1.11" -t "0.11.13"

#!/usr/bin/env bash
set -euo pipefail

# Arguments
declare go_version=""
declare tf_version=""
declare docker_img="msftcse/cobalt-test-base"
declare docker_file="test-harness\docker\base-images\Dockerfile"

usage(){
  echo "INFO: ***Cobalt Base Image Build Script***"
  echo "ERROR: Usage: $0 -t <terraform_version> -g <go_version>"
  exit 1
}

build_image(){
    echo "INFO: Building base image"
    declare docker_tag="g${go_version}t${tf_version}"
    docker build -f $docker_file \
        -t $docker_img:$docker_tag . \
        --build-arg gover=$go_version \
        --build-arg tfver=$tf_version
}

while getopts ":g:t:" arg; do
  case "$arg" in
    g) go_version="$OPTARG" ;;
    t) tf_version="$OPTARG" ;;
  esac
done
shift $((OPTIND-1))

if [ -z "$go_version" ]; then echo "ERROR: Go Version is not provided" >&2; usage; fi
if [ -z "$tf_version" ]; then echo "ERROR: Terraform is not provided" >&2; usage; fi

build_image