# Criação da Role (Identidade) para o EC2
resource "aws_iam_role" "ec2_ssm_role" {
  name = "cloudguard-ec2-ssm-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "cloudguard-ec2-role-${var.environment}"
  }
}

# Anexando a política de segurança do SSM à Role
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Criando o Perfil de Instância (A ponte entre a Role e a máquina EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "cloudguard-ec2-profile-${var.environment}"
  role = aws_iam_role.ec2_ssm_role.name
}