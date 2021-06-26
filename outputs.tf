output "vpc_id" {
    description = "The VPC ID"
    value       = "ID: ${module.network.vpc_id}"
}
output "vault_ip_address" {
  description = "Vault local container ip"
  value       = "Address for access vault: ${module.local_vault.vault_ip_address}"
}

output "vault_token" {
  description = "Vault local container token for access"
  value       = "use this token for access vault container: ${module.local_vault.vault_token}"
}
