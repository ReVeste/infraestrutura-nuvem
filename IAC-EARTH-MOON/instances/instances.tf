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

data "template_file" "nginx_config" {
  template = file("${path.module}/nginx-default.conf.tpl")

  vars = {
    backend1 = aws_instance.ec2_privada.private_ip
    backend2 = aws_instance.ec2_privada_2.private_ip
  }
}

resource "aws_instance" "ec2_publica" {
  ami             = "ami-0f9de6e2d2f067fca"
  instance_type   = "t2.micro"
  subnet_id       = var.subnet_publica_id
  key_name        = aws_key_pair.earth_moon.key_name
  security_groups = [var.security_public_id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install nginx -y

              echo '${data.template_file.nginx_config.rendered}' > /etc/nginx/sites-available/default
              systemctl restart nginx

              apt-get install ca-certificates curl -y
              install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              chmod a+r /etc/apt/keyrings/docker.asc

              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

              apt-get update -y
              apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

              systemctl start docker
              systemctl enable docker

              cat <<EOL > /home/ubuntu/docker-compose-front-end.yaml
              version: '3.8'

              services:
                front_end_1:
                  image: mirandark/earth-moon-front-end:latest
                  ports:
                    - "3000:80"

                front_end_2:
                  image: mirandark/earth-moon-front-end:latest
                  ports:
                    - "3001:80"
              EOL

              docker compose -f /home/ubuntu/docker-compose-front-end.yaml up -d
            EOF

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
set -xe

# Atualize os pacotes
apt update -y

# Instale pacotes necessários para usar o repositório Docker
apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Adicione a chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adicione o repositório Docker às fontes APT
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Atualize o APT novamente
apt update -y

# Instale o Docker e o plugin docker-compose
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Adicione o usuário ubuntu ao grupo docker para permitir executar docker sem sudo
usermod -aG docker ubuntu

# Ativa e inicia o serviço docker
systemctl enable docker
systemctl start docker

# Cria arquivo docker-compose (heredoc sem indentação)
cat <<EOL > /home/ubuntu/docker-compose-back-end.yaml
version: '3.8'

services:
  back_end_1:
    image: mirandark/earth-moon-back-end:latest
    ports:
      - "8080:80"

  back_end_2:
    image: mirandark/earth-moon-back-end:latest
    ports:
      - "8081:80"
EOL

# Ajusta propriedade do arquivo para o usuário ubuntu
chown ubuntu:ubuntu /home/ubuntu/docker-compose-back-end.yaml

# Executa o docker compose como usuário ubuntu
runuser -l ubuntu -c "docker compose -f /home/ubuntu/docker-compose-back-end.yaml up -d"
EOF

  tags = {
    Name = "EARTH-MOON-PRIVADA-1"
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
set -xe

# Atualize os pacotes
apt update -y

# Instale pacotes necessários para usar o repositório Docker
apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# Adicione a chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adicione o repositório Docker às fontes APT
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

# Atualize o APT novamente
apt update -y

# Instale o Docker e o plugin docker-compose
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Adicione o usuário ubuntu ao grupo docker para permitir executar docker sem sudo
usermod -aG docker ubuntu

# Ativa e inicia o serviço docker
systemctl enable docker
systemctl start docker

# Cria arquivo docker-compose (heredoc sem indentação)
cat <<EOL > /home/ubuntu/docker-compose-back-end.yaml
version: '3.8'

services:
  back_end_1:
    image: mirandark/earth-moon-back-end:latest
    ports:
      - "8080:80"

  back_end_2:
    image: mirandark/earth-moon-back-end:latest
    ports:
      - "8081:80"
EOL

# Ajusta propriedade do arquivo para o usuário ubuntu
chown ubuntu:ubuntu /home/ubuntu/docker-compose-back-end.yaml

# Executa o docker compose como usuário ubuntu
runuser -l ubuntu -c "docker compose -f /home/ubuntu/docker-compose-back-end.yaml up -d"
EOF

  tags = {
    Name = "EARTH-MOON-PRIVADA-2"
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