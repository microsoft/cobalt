output "gatewayurl" {
    description = "The url for managing the API manager"
    value = "${lookup(azurerm_template_deployment.apimgmt.outputs, "gatewayurl")}"
}

output "api_url" {
  description = "The ID of the API Management API."
  value       = "${azurerm_api_management_api.apimgmt.*.id}"
}
