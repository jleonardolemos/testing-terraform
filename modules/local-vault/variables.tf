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

variable "name" {
    type = string
    description = "vault aws var name"
    default = "dynamic-aws-creds-vault-admin" 
}

variable "aws_access_key" {
    type = string
    description = "aws root aws_access_key to create the AMI"
}

variable "aws_secret_key" {
    type = string
    description = "aws root aws_secret_key to create the AMI"
}