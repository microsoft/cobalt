data "azurerm_resource_group" "apimgmt" {
  name      = "${var.service_plan_resource_group_name}"
}

resource "azurerm_template_deployment" "apimgmt" {
  name                = "acctesttemplate-01"
  resource_group_name = "${data.azurerm_resource_group.apimgmt.name}"
  parameters = {
    "apimgmt_name"         = "${var.apimgmt_name}"
    "apimgmt_sku"          = "${var.apimgmt_sku}"
    "apimgmt_capacity"     = "${var.apimgmt_capacity}"
    "apimgmt_pub_name"     = "${var.apimgmt_pub_name}"
    "apimgmt_pub_email"    = "${var.apimgmt_pub_email}"
    "subnet_resource_id"   = "${var.subnet_resource_id}" 
    "virtual_network_type" = "${var.virtual_network_type}"
  }
  deployment_mode = "Incremental"
  template_body   = "${file("${path.module}/azuredeploy.json")}"
}

resource "azurerm_api_management_api" "apimgmt" {
  name                = "${var.api_name}-${count.index}"
  resource_group_name = "${data.azurerm_resource_group.apimgmt.name}"
  api_management_name = "${var.apimgmt_name}"
  revision            = "${var.revision}"
  display_name        = "${var.display_name} ${count.index}"
  path                = "${var.path}-${count.index}"
  protocols           = "${var.protocols}"
  service_url         = "https://${var.service_url[count.index]}"
  count               = "${length(var.service_url)}"
  depends_on          = ["azurerm_template_deployment.apimgmt"]
}

resource "azurerm_api_management_logger" "apimgmt" {
  name                = "${var.apimgmt_logger_name}"
  api_management_name = "${var.apimgmt_name}"
  resource_group_name = "${data.azurerm_resource_group.apimgmt.name}"
  depends_on          = ["azurerm_template_deployment.apimgmt"]

  application_insights {
    instrumentation_key = "${var.appinsghts_instrumentation_key}"
  }
}
