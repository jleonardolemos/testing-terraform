variable "vault_token" {
    type = string
    description = "Vault token"
    default = "root"
}

variable "vault_address" {
    type = string
    description = "Vault addres Ex: 0.0.0.0:8002"
    default = "0.0.0.0:8002"
}