output "app_service_default_hostname" {
  value = "https://${element(module.app_service.app_service_uri, 0)}"
}

