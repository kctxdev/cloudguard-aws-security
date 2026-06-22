output "instance_id" {
  description = "ID da Instância EC2"
  value       = aws_instance.server.id
}