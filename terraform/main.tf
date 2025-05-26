terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# SSM Parameter for API Key
resource "aws_ssm_parameter" "api_key" {
  name  = "/myapp/api-key"
  type  = "SecureString"
  value = var.api_key
}

# Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

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

# Lambda IAM Policy
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_execution_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = [aws_ssm_parameter.api_key.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = ["arn:aws:logs:*:*:*"]
      }
    ]
  })
}

# Lambda Functions
resource "aws_lambda_function" "health" {
  filename         = "../dist/lambda.zip"
  function_name    = "health-endpoint"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.healthHandler"
  source_code_hash = filebase64sha256("../dist/lambda.zip")
  runtime          = "nodejs18.x"
}

resource "aws_lambda_function" "echo" {
  filename         = "../dist/lambda.zip"
  function_name    = "echo-endpoint"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.echoHandler"
  source_code_hash = filebase64sha256("../dist/lambda.zip")
  runtime          = "nodejs18.x"
}

# API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "lambda-api"
}

# Health Endpoint
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.health.invoke_arn

  integration_http_method = "POST"
}

# Echo Endpoint
resource "aws_api_gateway_resource" "echo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "echo"
}

resource "aws_api_gateway_method" "echo" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.echo.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "echo" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.echo.id
  http_method = aws_api_gateway_method.echo.http_method
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.echo.invoke_arn

  integration_http_method = "POST"
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on  = [aws_api_gateway_integration.health, aws_api_gateway_integration.echo]
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}

# CloudWatch Alarm Example
resource "aws_cloudwatch_metric_alarm" "api_errors" {
  alarm_name          = "api-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors API Gateway 5XX errors"
  alarm_actions       = []

  dimensions = {
    ApiName = aws_api_gateway_rest_api.api.name
    Stage   = aws_api_gateway_stage.api.stage_name
  }
}