output "key_arn" {
  description = "ARN da Chave KMS criada"
  value       = aws_kms_key.main.arn
}