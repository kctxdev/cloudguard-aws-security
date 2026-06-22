output "bucket_id" {
  value       = aws_s3_bucket.security_bucket.id
  description = "O ID do bucket S3 criado"
}

output "bucket_arn" {
  value       = aws_s3_bucket.security_bucket.arn
  description = "O ARN do bucket S3 criado"
}