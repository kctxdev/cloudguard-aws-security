variable "environment" {
  type        = string
  description = "Nome do ambiente (dev ou prod)"
}
variable "vpc_id" {
  type        = string
  description = "ID da VPC criado pelo módulo de rede"
}