variable "aws_file_key_file_location" {
    type = string
    description = "Location for the aws shared keys"
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
}
