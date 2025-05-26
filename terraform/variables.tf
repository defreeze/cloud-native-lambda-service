variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "api_key" {
  description = "Dummy API key to store in SSM"
  type        = string
  sensitive   = true
}