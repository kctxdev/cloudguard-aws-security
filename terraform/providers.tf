provider "aws" {
  region = "var.aws_region"

  default_tags {
    tags = {
      Project     = "CloudGuard-AWS-Security"
      ManagedBy   = "Terraform"
      Environment = terraform.workspace # Pega o nome do ambiente atual
    }
  }
}