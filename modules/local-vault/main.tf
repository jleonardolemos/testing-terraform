# Start a container
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.12.2"
    }
  }
}

resource "docker_container" "vault" {
  name  = "vault"
  image = "vault"
  must_run = false
  env = [
      "VAULT_DEV_ROOT_TOKEN_ID=${var.vault_token}",
      "VAULT_DEV_LISTEN_ADDRESS=${var.vault_address}"
  ]
  capabilities {
    add = [
      "IPC_LOCK"
    ]
  }
}