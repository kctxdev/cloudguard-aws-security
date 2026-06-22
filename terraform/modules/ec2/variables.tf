variable "environment" {
  type        = string
  description = "Nome do ambiente (dev ou prod)"
}

variable "vpc_id" {
  type        = string
  description = "ID da VPC onde a EC2 será criada"
}

variable "subnet_id" {
  type        = string
  description = "ID da Subnet pública para a EC2"
}

variable "iam_instance_profile" {
  type        = string
  description = "Perfil do IAM para o SSM"
}
variable "ami_id" {
  type        = string
  description = "ID da AMI para a instância"
}

variable "instance_type" {
  type        = string
  description = "Tamanho/Tipo da instância EC2"
}