output "instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_profile.name # Ajuste "ec2_profile" se o nome do seu recurso for diferente
  description = "Nome do IAM Instance Profile para a EC2"
}