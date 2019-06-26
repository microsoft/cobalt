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
RUN apt-get update && apt-get install -y build-essential wget unzip azure-cli
ENV GOLANG_VERSION=$gover

ENV PATH /usr/local/go/bin:/usr/local/go:$PATH
ENV GOPATH $HOME/go
ENV GOBIN /usr/local/go

# Install Terraform
ARG tfver=0.12.2
ENV TF_VERSION=$tfver
RUN wget --quiet https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
  && unzip terraform_${TF_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TF_VERSION}_linux_amd64.zip

# setup project workspace
WORKDIR $HOME/app/

ADD go.mod go.sum ./
RUN ["go", "mod", "download"]

CMD bash