# Criação da Chave Criptográfica Mestra
resource "aws_kms_key" "main" {
  description             = "Chave mestra de criptografia para o ambiente ${var.environment}"
  deletion_window_in_days = 30
  enable_key_rotation     = true # Prática Enterprise: A AWS rotaciona a chave automaticamente 1x por ano

  tags = {
    Name = "cloudguard-kms-${var.environment}"
  }
}

# Criando um 'Apelido' para a chave (facilita achar no painel da AWS)
resource "aws_kms_alias" "main_alias" {
  name          = "alias/cloudguard-${var.environment}"
  target_key_id = aws_kms_key.main.key_id
}