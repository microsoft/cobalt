output "cert_name" {
  value = "${var.key_vault_cert_name}"
}

output "public_cert" {
  value     = "${lookup(data.external.public_cert.result, "cer")}"
  sensitive = true
}

output "private_pfx" {
  value     = "${lookup(data.external.private_pfx.result, "value")}"
  sensitive = true
}
