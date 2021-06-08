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
  shared_credentials_file = var.aws_file_key_file_location
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id = var.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}


resource "aws_security_group" "allow_swarm_manager" {
  name        = "allow_swarm_manager"
  description = "Allow Swarm Manager"
  vpc_id = var.vpc_id

  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_swarm_manager"
  }
}

resource "aws_security_group" "allow_swarm_advertise" {
  name        = "allow_swarm_advertise"
  description = "Allow Swarm Advertise"
  vpc_id = var.vpc_id

  ingress {
    from_port        = 2377
    to_port          = 2377
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_swarm_advertise"
  }
}

resource "aws_instance" "swarm_manager" {
  ami           = "ami-09e67e426f25ce0d7"
  associate_public_ip_address = "true"
  instance_type = "t2.micro"
  key_name = "ecs-key"
  subnet_id = var.subnet
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http.id,
    aws_security_group.allow_swarm_manager.id,
    aws_security_group.allow_swarm_advertise.id,
  ]

  tags = {
    Name = "Manager"
  }

  provisioner "file" {
    source      = "./modules/swarm-manager/docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = self.public_ip
      private_key = file(var.manager_private_key_file_location)
    }
  }

  provisioner "remote-exec" {
    script = "${path.module}/user_data.sh"
    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = self.public_ip
      private_key = file(var.manager_private_key_file_location)
    }
  }
}