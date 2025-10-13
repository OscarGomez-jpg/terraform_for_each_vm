# Data source para obtener la AMI más reciente de Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (propietario oficial de Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group - equivalente a Network Security Group de Azure
resource "aws_security_group" "devops_sg" {
  name        = "${var.prefix_name}-sg"
  description = "Security group para servidores DevOps"
  vpc_id      = var.vpc_id

  # Regla SSH (puerto 22)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla HTTP (puerto 80)
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla HTTPS (puerto 443)
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla SonarQube (puerto 9000)
  ingress {
    description = "SonarQube"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla Jenkins (puerto 8080)
  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico de salida
  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix_name}-sg"
  }
}

# Instancias EC2 - equivalente a Linux Virtual Machine de Azure
resource "aws_instance" "vm_devops" {
  for_each = var.servers

  ami           = data.aws_ami.ubuntu.id
  instance_type = lookup(var.instance_types, each.value, var.instance_type)
  key_name      = var.key_name
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  # Asignar IP pública automáticamente
  associate_public_ip_address = true

  # Configuración del disco raíz (equivalente a os_disk de Azure)
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 15 # 15 GB × 2 instancias = 30 GB total (Free Tier: 30 GB)
    delete_on_termination = true
    encrypted             = false

    tags = {
      Name = "${each.value}-root-disk"
    }
  }

  # User data para configuración inicial (opcional)
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get upgrade -y
              EOF

  tags = {
    Name = "${each.value}-instance"
  }
}