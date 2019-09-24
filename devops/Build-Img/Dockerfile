FROM ubuntu:16.04

ENV GOLANG_VERSION 1.12.5
ENV TERRAFORM_VERSION 0.12.4

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
		apt-transport-https \
        ca-certificates \
		gnupg-agent \
		software-properties-common \
        unzip \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl3 \
        libicu55 \
        libunwind8 \
        netcat && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -sSL https://storage.googleapis.com/golang/go$GOLANG_VERSION.linux-amd64.tar.gz | \
    tar -v -C /usr/local -xz && \
    mkdir -p /go/src /go/bin && chmod -R 777 /go && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash

ENV PATH /usr/local/go/bin:$PATH
ENV GOROOT /usr/local/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH