output "app_gateway_health_probe_backend_status" {
  value = module.app_gateway.appgateway_health_probe_backend_status
}

output "app_gateway_health_probe_backend_address" {
  value = module.app_gateway.app_gateway_health_probe_backend_address
}

output "tm_fqdn" {
  value = module.traffic_manager.public_pip_fqdn
}

output "public_cert" {
  value = module.keyvault_certificate.public_cert
}

