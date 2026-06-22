# ==========================================
# 1. Criação da Role do IAM para a Lambda
# ==========================================
resource "aws_iam_role" "lambda_role" {
  name = "cloudguard-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Política básica para a Lambda conseguir escrever logs no CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ==========================================
# 2. BASE: Criação da Função Lambda
# ==========================================
resource "aws_lambda_function" "security_lambda" {
  filename      = "${path.module}/lambda_function.zip"
  function_name = "cloudguard-defender-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
}

# ==========================================
# 3. Criar regra no EventBridge para escutar alertas do GuardDuty
# ==========================================
resource "aws_cloudwatch_event_rule" "guardduty_alerts" {
  name        = "cloudguard-guardduty-rule-${var.environment}"
  description = "Captura descobertas do GuardDuty e envia para a Lambda de defesa"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
}

# ==========================================
# 4. Conectar a regra do EventBridge à Lambda
# ==========================================
resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule      = aws_cloudwatch_event_rule.guardduty_alerts.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.security_lambda.arn
}

# ==========================================
# 5. Dar permissão para o EventBridge rodar a Lambda
# ==========================================
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.security_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty_alerts.arn
}