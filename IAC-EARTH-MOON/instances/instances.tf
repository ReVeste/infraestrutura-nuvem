variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_publica_id" {
  description = "ID da Subnet Pública"
  type        = string
}

variable "subnet_private_id" {
  description = "ID da Subnet Privada"
  type        = string
}

variable "security_public_id" {
  description = "ID do Security Group de Jump"
  type        = string
}

variable "security_private_id" {
  description = "ID do Security Group Privado"
  type        = string
}




resource "aws_instance" "ec2_publica" {
  ami             = "ami-0f9de6e2d2f067fca"
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_publica_id
  key_name        = aws_key_pair.earth_moon.key_name
  security_groups = [var.security_public_id]


  user_data = <<-EOF2
            #!/bin/bash

            sudo apt-get update -y
            sudo apt install nginx -y

            sudo bash -c 'cat > /etc/nginx/sites-available/default' <<EOL

            upstream backend_servers {
                least_conn;
                server ${aws_instance.ec2_privada.private_ip}:8080;
                server ${aws_instance.ec2_privada_2.private_ip}:8080;
            }

            server {
                listen 80;
                server_name _;

                 location /api/ {
                    proxy_pass http://backend_servers;
                    proxy_set_header Host $$host;
                    proxy_set_header X-Real-IP $$remote_addr;
                    proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                  location ~* /swagger-ui/ {
                      proxy_pass http://backend_servers;
                      proxy_set_header Host $$host;
                      proxy_set_header X-Real-IP $$remote_addr;
                      proxy_set_header X-Forwarded-For $$proxy_add_x_forwarded_for;
                      proxy_set_header X-Forwarded-Proto $$scheme;
                  }

                  location / {
                      proxy_pass http://localhost:3000;
                      proxy_http_version 1.1;
                      proxy_set_header Upgrade $$http_upgrade;
                      proxy_set_header Connection 'upgrade';
                      proxy_set_header Host $$host;
                      proxy_cache_bypass $$http_upgrade;
                  }
            }

            EOL

            sudo systemctl restart nginx


            sudo apt-get update -y
            sudo apt-get install ca-certificates curl

            sudo install -m 0755 -d /etc/apt/keyrings -y
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt-get update -y
            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

            sudo systemctl start docker
            sudo systemctl enable docker

            sudo groupadd docker
            sudo usermod -aG docker $USER
            newgrp docker

            sudo docker run -p 3000:80 -d mirandark/earth-moon-front-end:v2.2


          EOF2

  tags = {
    Name = "EARTH-MOON-PUBLICA"
  }
}


resource "aws_instance" "ec2_privada" {
  ami             = "ami-0f9de6e2d2f067fca"
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_private_id
  key_name        = aws_key_pair.earth_moon.key_name
  security_groups = [var.security_private_id]

  user_data = <<-EOF
            #!/bin/bash
            
            sudo apt-get update -y
            sudo apt-get install ca-certificates curl

            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt-get update -y
            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

            sudo systemctl start docker
            sudo systemctl enable docker

            sudo groupadd docker
            sudo usermod -aG docker $USER
            newgrp docker

            sudo docker run -p 8080:8080 -d mirandark/earth-moon-back-end:v2.2
          EOF

  tags = {
    Name = "EARTH-MOON-PRIVADA"
  }
}

resource "aws_instance" "ec2_privada_2" {
  ami             = "ami-0f9de6e2d2f067fca"
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_private_id
  key_name        = aws_key_pair.earth_moon.key_name
  security_groups = [var.security_private_id]

  user_data = <<-EOF
            #!/bin/bash
            
            sudo apt-get update -y
            sudo apt-get install ca-certificates curl

            sudo install -m 0755 -d /etc/apt/keyrings
            sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            sudo chmod a+r /etc/apt/keyrings/docker.asc

            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            sudo apt-get update -y
            sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

            sudo systemctl start docker
            sudo systemctl enable docker

            sudo groupadd docker
            sudo usermod -aG docker $USER
            newgrp docker

            sudo docker run -p 8080:8080 -d mirandark/earth-moon-back-end:v2.2
          EOF

  tags = {
    Name = "EARTH-MOON-PRIVADA"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "earth_moon" {
  key_name   = "earth_moon"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/../keys/earth_moon.pem"
  file_permission = "0400"
}


output "public_instance_id" {
  value = aws_instance.ec2_publica.id
  description = "ID da instância EC2 pública"
}

output "private_instance_id" {
  value = aws_instance.ec2_privada.id
  description = "ID da instância EC privado"
}