# Criação da VPC Principal
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "cloudguard-vpc-${var.environment}"
  }
}

# Sub-rede Pública (Com acesso à Internet)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "cloudguard-public-subnet-${var.environment}"
  }
}

# Sub-rede Privada (Sem acesso direto à Internet para maior segurança)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = "us-east-1a"

  tags = {
    Name = "cloudguard-private-subnet-${var.environment}"
  }
}

# Gateway de Internet (Porta de saída para a rede pública)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "cloudguard-igw-${var.environment}"
  }
}

# Tabela de Roteamento para a Sub-rede Pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "cloudguard-public-rt-${var.environment}"
  }
}

# Associando a Tabela de Roteamento à Sub-rede Pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}