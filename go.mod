module github.com/microsoft/cobalt

go 1.12

require (
	contrib.go.opencensus.io/exporter/ocagent v0.4.2 // indirect
	git.apache.org/thrift.git v0.0.0-20180902110319-2566ecd5d999 // indirect
	github.com/Azure/azure-sdk-for-go v38.1.0+incompatible
	github.com/Azure/go-autorest v11.7.0+incompatible
	github.com/gruntwork-io/gruntwork-cli v0.6.1 // indirect
	github.com/gruntwork-io/terratest v0.26.5
	github.com/imdario/mergo v0.3.9 // indirect
	github.com/magefile/mage v1.8.0
	github.com/microsoft/terratest-abstraction v0.0.0-20200417192312-d2dd8b2c5d11
	github.com/microsoft/terratestabstraction v0.0.0-20200417134526-63455a5441b3
	github.com/openzipkin/zipkin-go v0.1.1 // indirect
	github.com/otiai10/copy v1.1.1 // indirect
	github.com/stretchr/testify v1.4.0
	golang.org/x/time v0.0.0-20191024005414-555d28b269f0 // indirect
	k8s.io/api v0.18.1 // indirect
	k8s.io/client-go v11.0.0+incompatible // indirect
	k8s.io/utils v0.0.0-20200411171748-3d5a2fe318e4 // indirect
)

replace git.apache.org/thrift.git => github.com/apache/thrift v0.12.0
