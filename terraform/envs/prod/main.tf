module "vpc" {
  source              = "../../modules/vpc"
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

module "iam" {
  source      = "../../modules/iam"
  environment = var.environment
}

module "ec2" {
  source               = "../../modules/ec2"
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.public_subnet_id
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  iam_instance_profile = module.iam.instance_profile_name
}

module "s3" {
  source      = "../../modules/s3"
  environment = var.environment
}

module "monitoring" {
  source      = "../../modules/monitoring"
  environment = var.environment
}

module "security_response" {
  source      = "../../modules/security-response"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}