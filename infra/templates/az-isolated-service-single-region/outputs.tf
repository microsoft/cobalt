output "fqdns" {
  value = [
      for uri in module.app_service.app_service_uri:
        "http://${uri}"
  ]
}