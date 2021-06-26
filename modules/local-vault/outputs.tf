output "vault_ip_address" {
  description = "Vault local container ip"
  value       = docker_container.vault.ip_address
}

output "vault_token" {
  description = "Vault local container token for access"
  value       = var.vault_token
}
