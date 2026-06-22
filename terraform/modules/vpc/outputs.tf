output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID da Sub-rede Pública"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID da Sub-rede Privada"
  value       = aws_subnet.private.id
}