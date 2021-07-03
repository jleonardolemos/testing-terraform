# Start a container
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.12.2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "2.17.0"
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

provider "vault" {
  address = "http://172.17.0.2:8002"
  token = var.vault_token
}

resource "vault_aws_secret_backend" "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  path       = "${var.name}-path"

  default_lease_ttl_seconds = "120"
  max_lease_ttl_seconds     = "240"
}

resource "vault_aws_secret_backend_role" "admin" {
  backend         = vault_aws_secret_backend.aws.path
  name            = "${var.name}-role"
  credential_type = "iam_user"

  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*", "ec2:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
