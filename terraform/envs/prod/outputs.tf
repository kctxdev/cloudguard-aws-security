output "ambiente" { value = var.environment }
output "prod_vpc_id" { value = module.vpc.vpc_id }
output "prod_ec2_id" { value = module.ec2.instance_id }
output "prod_s3_bucket" { value = module.s3.bucket_id }