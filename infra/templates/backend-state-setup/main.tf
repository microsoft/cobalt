module "provider" {
  source = "github.com/Microsoft/bedrock/cluster/azure/provider"
}

module "backend-state-setup" {
  source   = "github.com/Microsoft/bedrock/cluster/azure/backend-state"
  name     = "${var.name}"
  location = "${var.location}"
}
