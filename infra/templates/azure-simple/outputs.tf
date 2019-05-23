output "app_gateway_health_probes" {
  value = ["${module.app_gateway.appgateway_backend_health}"]
}

output "tm_fqdn" {
  value = "${module.traffic_manager.public_pip_fqdn}"
}
