# Busca a imagem mais recente do Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Grupo de Segurança ultra-restrito (Nenhuma porta de entrada aberta)
resource "aws_security_group" "ec2_sg" {
  name        = "cloudguard-ec2-sg-${var.environment}"
  description = "Security Group para EC2 - Acesso apenas via SSM"
  vpc_id      = var.vpc_id

  # Regra de saída: O servidor pode acessar a internet para baixar atualizações
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudguard-ec2-sg-${var.environment}"
  }
}

# Criação do Servidor EC2
resource "aws_instance" "server" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t2.micro" # Opção gratuita (Free Tier)
  subnet_id            = var.subnet_id
  iam_instance_profile = var.iam_instance_profile

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # Como o acesso é via SSM, não precisamos de chave SSH (Key Pair)

  tags = {
    Name = "cloudguard-server-${var.environment}"
  }
}