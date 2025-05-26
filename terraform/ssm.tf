resource "aws_ssm_parameter" "api_key" {
  name        = "/myapp/api-key"
  description = "API Key for the service"
  type        = "SecureString"
  value       = var.api_key

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
} 