output "sns_topic_arn" {
  value       = aws_sns_topic.security_alerts.arn
  description = "O ARN do tópico SNS para alertas de segurança"
}