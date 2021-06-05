variable "vpc_id" {
    type = string
    description = "vpc id"
}

variable "subnet_one" {
    type = string
    description = "instance subnet public one"
}

variable "subnet_two" {
    type = string
    description = "instance subnet public two"
}

variable "aws_file_key_file_location" {
    type = string
    description = "Location for the aws shared keys"
}

variable "manager_private_key_file_location" {
    type = string
    description = "Location for the manager private key"
}