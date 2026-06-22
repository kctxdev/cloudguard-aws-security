variable "environment" {
  type        = string
  description = "Nome do ambiente (dev ou prod)"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN da chave KMS para criptografia (opcional)"
  default     = null
}