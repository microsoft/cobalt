ARG gover
FROM golang:$gover

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git curl apt-transport-https lsb-release gpg

# Install Azure CLI
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ stretch main" | \
    tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update

RUN apt-get install -y azure-cli
# Set go bin which doesn't appear to be set already.
ENV GOBIN /go/bin

RUN mkdir /app
RUN mkdir /go/src/app
#ADD . /go/src/app

# Go dep!
RUN go get -u github.com/golang/dep/...

# Go Mage!
RUN go get -u github.com/magefile/mage
WORKDIR $GOPATH/src/github.com/magefile/mage
RUN go run bootstrap.go

WORKDIR /go/src/app
CMD bash
