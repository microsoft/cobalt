# azure-simple

The `single-region` environment is a non-production ready template we provide to easily try out Cobalt on Azure.

## Getting Started

1. Copy this template directory to a repository of its own. Cobalt environments remotely reference the Terraform and [Bedrock](https://github.com/Microsoft/bedrock/tree/1015539411a631dcc48ad0564550cb3c2d4ced84/cluster/azure) modules that they need and do not need be housed in the Cobalt repository.