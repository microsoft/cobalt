output "cert_name" {
  value = var.key_vault_cert_name
}

output "public_cert" {
  value     = data.external.public_cert.result["cer"]
  sensitive = true
}

output "private_pfx" {
  value     = data.external.private_pfx.result["value"]
  sensitive = true
}

output "vault_id" {
  value = data.azurerm_key_vault.vault.id
}

