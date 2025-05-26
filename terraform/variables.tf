variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "cloud-native-lambda-service"
}

variable "environment" {
  description = "Environment (dev, prod, etc)"
  type        = string
  default     = "dev"
}

variable "api_key" {
  description = "API Key to store in SSM Parameter Store"
  type        = string
  sensitive   = true
} 