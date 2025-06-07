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

  # lifecycle {
  #   prevent_destroy = true
  # }

}

resource "aws_eip_association" "assoc_ip_publica" {
  instance_id   = module.instances.public_instance_id
  allocation_id = aws_eip.ip_instancia-publica.id
}

resource "aws_eip" "ip_instancia-privada" {
  vpc = true

  tags = {
    Name = "EARTH-MOON-NOVO-IP-PRIVADO"
  }

  # lifecycle {
  #   prevent_destroy = true
  # }

}

resource "aws_eip_association" "assoc_ip_privada" {
  instance_id   = module.instances.private_instance_id
  allocation_id = aws_eip.ip_instancia-privada.id
}


# enviar chave pem das intancia publica e privada para instância pública
# scp -i keys/earth_moon.pem keys/earth_moon.pem ubuntu@[ip publico]:/home/ubuntu/.ssh/earth_moon.pem
# scp -i keys/earth_moon.pem keys/earth_moon.pem ubuntu@34.206.47.111:/home/ubuntu/.ssh/earth_moon.pem


# enviar chave pem do banco de dados para instância pública
# scp -i keys/earth_moon.pem keys/earth-moon-database.pem ubuntu@[ip publico]:/home/ubuntu/.ssh/earth-moon-database.pem
# scp -i keys/earth_moon.pem keys/earth-moon-database.pem ubuntu@3.209.222.70:/home/ubuntu/.ssh/earth-moon-database.pem


# enviar chave pem para intancia privada
# scp -i keys/earth_moon.pem keys/earth_moon.pem ubuntu@[ip privado]:/home/ubuntu/.ssh/earth_moon.pem
# scp -i .ssh/earth_moon.pem .ssh/earth_moon.pem ubuntu@10.0.1.112:/home/ubuntu/.ssh/earth_moon.pem


# enviar chave pem do banco de dados para intancia privada
# scp -i .ssh/earth-moon-database.pem .ssh/earth-moon-database.pem ubuntu@[ip privado]:/home/ubuntu/.ssh/earth-moon-database.pem
# scp -i .ssh/earth-moon-database.pem .ssh/earth-moon-database.pem ubuntu@10.0.1.112:/home/ubuntu/.ssh/earth-moon-database.pem


# earth-moon-database
