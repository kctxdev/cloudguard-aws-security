resource "aws_sns_topic" "security_alerts" {
  name = "cloudguard-security-alerts-${var.environment}"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = "seu-email@exemplo.com" # Altere para o seu e-mail de alertas
}