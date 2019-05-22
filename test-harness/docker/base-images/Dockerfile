# Description: Base image used for running the golang terratest pipeline. 
# Usage: 
# build-
# docker build --rm -f "test-harness/Dockerfile" \
#         -t msftcse/cobalt-test-base:1 . \
#         --build-arg build_directory="$BUILD_TEMPLATE_DIRS" \
#         --build-arg base_img_tag="$TEST_HARNESS_BASE_IMAGE_TAG"
# 
# Base image-
# ARG base_img_tag
# FROM msftcse/cobalt-test-base:$base_img_tag

ARG gover
FROM golang:${gover}-stretch as build
RUN apt-get update && \
    apt-get install -y git curl apt-transport-https lsb-release gpg



# Setup Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ stretch main" | \
    tee /etc/apt/sources.list.d/azure-cli.list

# Install Azure CLI + core compilers like gcc which are required for dep
RUN apt-get update && apt-get install -y build-essential wget unzip
ENV GOLANG_VERSION=$gover

ENV PATH /usr/local/go/bin:/usr/local/go:$PATH
ENV GOPATH $HOME/go
ENV GOBIN /usr/local/go

# Install Terraform
ARG tfver=0.11.3
ENV TF_VERSION=$tfver
RUN wget --quiet https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
  && unzip terraform_${TF_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TF_VERSION}_linux_amd64.zip

# Go dep!
RUN /bin/bash -c "curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh"

# setup project workspace
WORKDIR $HOME/app/

# Copy over go unit / int tests + mage manifest
ADD *.go ./
RUN mkdir infra build
ADD infra/ ./infra
ADD test-harness/infratests/ ./test-harness/infratests

RUN apt-get purge -y wget build-essential wget unzip curl \
    apt-transport-https lsb-release gpg

# This initializes the name of the module
RUN ["go", "mod", "init", "github.com/microsoft/cobalt"]
# This command will look for local packages and will inflate go.mod and go.sum along the way.
# It will also pull down any missing dependencies.
RUN ["go", "list", "./..."]
RUN rm -r ./infra

CMD bash