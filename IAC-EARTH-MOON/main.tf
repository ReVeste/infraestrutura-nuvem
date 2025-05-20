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


}

resource "aws_eip_association" "assoc_ip_publica" {
  instance_id   = module.instances.public_instance_id
  allocation_id = aws_eip.ip_instancia-publica.id
}

# importar ip elastico 
# terraform import aws_eip.ip_instancia-publica eipalloc-0feceac718b2c971d

# copiar chave pem para pública
# scp -i keys/earth_moon.pem keys/earth_moon.pem ubuntu@107.23.40.115:/home/ubuntu/.ssh/earth_moon.pem

# ssh -i "keys/earth_moon.pem" ubuntu@ec2-107-23-40-115.compute-1.amazonaws.com
# http://3.91.241.173/api/swagger-ui/index.html
# docker run -p 8080:8080 -d matteusnogueira/autohub-backend:v1
# docker logs $(docker ps -q --filter matteusnogueira/autohub-backend)
