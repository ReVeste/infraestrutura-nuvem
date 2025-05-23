terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

module "network" {
  source = "./network"
}


module "instances" {
  source               = "./instances"
  vpc_id               = module.network.vpc_id
  subnet_publica_id    = module.network.subnet_publica_id
  subnet_private_id    = module.network.subnet_private_id
  security_public_id   = module.network.security_public_id
  security_private_id  = module.network.security_private_id
}

resource "aws_eip" "ip_instancia-publica" {
  vpc = true

  tags = {
    Name = "EARTH-MOON-NOVO-IP-PUBLICA"
  }

  lifecycle {
    prevent_destroy = true
  }

}

# data "aws_eip" "ip_instancia-publica" {
#   public_ip = "13.217.123.64" # Substitua pelo IP público da instância EC2 pública 
# }

resource "aws_eip_association" "assoc_ip_publica" {
  instance_id   = module.instances.public_instance_id
  allocation_id = aws_eip.ip_instancia-publica.id
}

# resource "aws_eip_association" "assoc_ip_publica" {
#   instance_id   = module.instances.public_instance_id
#   allocation_id = data.aws_eip.ip_instancia-publica.id
# }

resource "aws_eip" "ip_instancia-privada" {
  vpc = true

  tags = {
    Name = "EARTH-MOON-NOVO-IP-PRIVADO"
  }

  lifecycle {
    prevent_destroy = true
  }

}

# Referência ao IP elástico privado criado fora do Terraform (caso esteja usando um)
# data "aws_eip" "ip_instancia-privada" {
#   public_ip = "35.171.135.32" # Substitua com o IP elástico vinculado à instância privada, se houver
# }

resource "aws_eip_association" "assoc_ip_privada" {
  instance_id   = module.instances.private_instance_id
  allocation_id = aws_eip.ip_instancia-privada.id
}

# resource "aws_eip_association" "assoc_ip_privada" {
#   instance_id   = module.instances.private_instance_id
#   allocation_id = data.aws_eip.ip_instancia-privada.id
# }

# scp -i keys/earth_moon.pem keys/earth_moon.pem ubuntu@3.209.222.70:/home/ubuntu/.ssh/earth_moon.pem
# scp -i keys/earth_moon.pem keys/earth-moon-database.pem ubuntu@3.209.222.70:/home/ubuntu/.ssh/earth-moon-database.pem
# scp -i .ssh/earth_moon.pem .ssh/earth_moon.pem ubuntu@10.0.1.112:/home/ubuntu/.ssh/earth_moon.pem
# scp -i .ssh/earth-moon-database.pem .ssh/earth-moon-database.pem ubuntu@10.0.1.112:/home/ubuntu/.ssh/earth-moon-database.pem
# earth-moon-database
# ssh -i "keys/autohub_chave.pem" ubuntu@ec2-52-203-203-23.compute-1.amazonaws.com
# http://3.91.241.173/api/swagger-ui/index.html
# docker run -p 8080:8080 -d matteusnogueira/autohub-backend:v1
# docker logs $(docker ps -q --filter matteusnogueira/autohub-backend)
