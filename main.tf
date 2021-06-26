variable "aws_file_key_file_location" {
    type = string
    description = "Location for the aws shared keys"
}

variable "manager_private_key_file_location" {
    type = string
    description = "Location for the manager private key"
}

module "local_vault" {
  source = "./modules/local-vault"
}

module "network" {
  source = "./modules/network"

  aws_file_key_file_location = var.aws_file_key_file_location
}

module "swarm_manager" {
  source = "./modules/swarm-manager"

  subnet = module.network.subnet_id
  vpc_id = module.network.vpc_id
  aws_file_key_file_location = var.aws_file_key_file_location
  manager_private_key_file_location = var.manager_private_key_file_location
}

module "swarm_workers" {
  source = "./modules/swarm-workers"

  subnet_one = module.network.subnet_id
  subnet_two = module.network.subnet_id_2
  vpc_id = module.network.vpc_id
  aws_file_key_file_location = var.aws_file_key_file_location
  manager_private_key_file_location = var.manager_private_key_file_location
}
