ARG gover
FROM golang:${gover}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git curl apt-transport-https lsb-release gpg

# Setup Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ stretch main" | \
    tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update

# Install Azure CLI + core compilers like gcc which are required for dep
RUN apt-get install -y azure-cli build-essential wget unzip
ENV GOLANG_VERSION=$gover

ENV PATH /usr/local/go/bin:/usr/local/go:$PATH
ENV GOPATH $HOME/go
ENV GOBIN /usr/local/go
WORKDIR $GOPATH/src

# Install Terraform
ARG tfver=0.11.3
ENV TF_VERSION=$tfver
RUN wget --quiet https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip \
  && unzip terraform_${TF_VERSION}_linux_amd64.zip \
  && mv terraform /usr/bin \
  && rm terraform_${TF_VERSION}_linux_amd64.zip

RUN mkdir /app

# Go dep!
RUN /bin/bash -c "curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh"
RUN dep version

# Setup go app workspace
WORKDIR $GOPATH/src/app

# Copy over go unit / int tests + mage manifest
ADD *.go ./
RUN mkdir infra
ADD infra/ ./infra

# Pull down golang vendor dependenies
RUN ["dep", "init", "-v"]
RUN ["dep", "ensure", "-update", "-v"]
RUN rm -r ./infra
CMD bash