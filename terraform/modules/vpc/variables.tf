variable "environment" {
  type        = string
  description = "Nome do ambiente (dev ou prod)"
}

variable "vpc_cidr" {
  type        = string
  description = "Bloco CIDR principal da VPC"
}

# 🚨 ADICIONE ESSAS DUAS VARIÁVEIS ABAIXO SE NÃO ESTIVEREM LÁ:
variable "public_subnet_cidr" {
  type        = string
  description = "Bloco CIDR para a subnet pública"
}

variable "private_subnet_cidr" {
  type        = string
  description = "Bloco CIDR para a subnet privada"
}