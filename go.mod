module github.com/microsoft/cobalt

go 1.12

require (
	github.com/Azure/azure-sdk-for-go v38.1.0+incompatible
	github.com/Azure/go-autorest/autorest v0.9.3
	github.com/Azure/go-autorest/autorest/adal v0.8.1
	github.com/Azure/go-autorest/autorest/azure/auth v0.4.2
	github.com/gruntwork-io/terratest v0.26.5
	github.com/magefile/mage v1.8.0
	github.com/microsoft/terratest-abstraction v0.0.0-20200417192312-d2dd8b2c5d11
	github.com/otiai10/copy v1.1.1 // indirect
	github.com/stretchr/testify v1.4.0
	gopkg.in/yaml.v2 v2.2.8 // indirect
)

replace git.apache.org/thrift.git => github.com/apache/thrift v0.12.0
