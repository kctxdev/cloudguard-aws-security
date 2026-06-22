terraform {
  backend "s3" {
    bucket         = "cloudguard-tf-state-SEU_NOME_AQUI"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "cloudguard-tf-locks" # Agora está ativo! Isso garante o State Locking.
  }
}