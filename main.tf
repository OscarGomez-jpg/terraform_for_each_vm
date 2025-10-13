# VPC (Virtual Private Cloud) - equivalente a Virtual Network de Azure
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.prefix_name}-vpc"
  }
}

# Internet Gateway - para acceso a internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix_name}-igw"
  }
}

# Subnet pública
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.prefix_name}-subnet"
  }
}

# Route Table - para enrutar tráfico a internet
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.prefix_name}-rt"
  }
}

# Asociar Route Table con Subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Data source para obtener las zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}

# Módulo de VMs (ahora instancias EC2)
module "vm" {
  source        = "./modules/vm"
  servers       = var.servers
  instance_type = "t3.micro"  # Tipo por defecto (Free Tier)
  instance_types = {
    jenkins = "t3.medium"  # 4 GB RAM para Jenkins + SonarQube + PostgreSQL (~$7.00/semana)
    nginx   = "t3.micro"   # 1 GB RAM suficiente para Nginx (Free Tier)
  }
  subnet_id   = aws_subnet.main.id
  vpc_id      = aws_vpc.main.id
  prefix_name = var.prefix_name
  key_name    = var.key_name
}