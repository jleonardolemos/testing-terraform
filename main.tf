variable "aws_access_key" {
    type = string
    description = "AWS access key from IAM"
}

variable "aws_secret_key" {
    type = string
    description = "AWS secret from IAM"
}

variable "manager_private_key_file_location" {
    type = string
    description = "Location for the manager private key"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region                  = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

module "local_vault" {
  source = "./modules/local-vault"

  aws_access_key = var.aws_access_key
  aws_secret_key = var.aws_secret_key
}

module "network" {
  source = "./modules/network"
}

module "swarm_manager" {
  source = "./modules/swarm-manager"

  subnet = module.network.subnet_id
  vpc_id = module.network.vpc_id
  manager_private_key_file_location = var.manager_private_key_file_location
}

module "swarm_workers" {
  source = "./modules/swarm-workers"

  subnet_one = module.network.subnet_id
  subnet_two = module.network.subnet_id_2
  vpc_id = module.network.vpc_id
  manager_private_key_file_location = var.manager_private_key_file_location
}
