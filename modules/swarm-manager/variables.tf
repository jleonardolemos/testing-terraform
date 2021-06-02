variable "vpc_id" {
    type = string
    description = "vpc id"
}

variable "subnet" {
    type = string
    description = "instance subnet"
}

variable "aws_file_key_file_location" {
    type = string
    description = "Location for the aws shared keys"
}

variable "manager_private_key_file_location" {
    type = string
    description = "Location for the manager private key"
}