terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# Lambda functions
resource "aws_lambda_function" "health" {
  filename         = "../dist/index.js"
  function_name    = "${var.project_name}-health"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.healthHandler"
  runtime         = "nodejs20.x"

  environment {
    variables = {
      NODE_ENV = var.environment
    }
  }
}

resource "aws_lambda_function" "echo" {
  filename         = "../dist/index.js"
  function_name    = "${var.project_name}-echo"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.echoHandler"
  runtime         = "nodejs20.x"

  environment {
    variables = {
      NODE_ENV = var.environment
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "main" {
  api_id = aws_apigatewayv2_api.main.id
  name   = var.environment
  auto_deploy = true
}

# API Gateway routes
resource "aws_apigatewayv2_integration" "health" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.health.invoke_arn
}

resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.health.id}"
}

resource "aws_apigatewayv2_integration" "echo" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.echo.invoke_arn
}

resource "aws_apigatewayv2_route" "echo" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /echo"
  target    = "integrations/${aws_apigatewayv2_integration.echo.id}"
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "health" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "echo" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.echo.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "api_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-api-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors API Gateway 5XX errors"
  treat_missing_data  = "notBreaching"
} 