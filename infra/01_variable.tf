# variable.tf
##############################
# App level
##############################
variable "app_name" {
  description = "Application name"
  type        = string
  default     = "bedrock-log-analyst"
}

variable "env" {
  description = "Envrionment"
  type        = string
  default     = "demo"
}

variable "dns_domain" {
  description = "Domain name"
  type        = string
}

variable "dns_subdomain" {
  description = "Sub-domain name"
  type        = string
}

# ##############################
# # AWS provider
# ##############################
variable "aws_region" {
  description = "AWS region"
  type        = string
}

##############################
# AWS lambda
##############################
variable "lambda_runtime" {
  description = "AWS lambda function runtime"
  type        = string
  default     = "python3.11"
}

variable "lambda_handler" {
  description = "AWS lambda function handler"
  type        = string
  default     = "bot.lambda_handler"
}

variable "lambda_file_path" {
  description = "Lambda function source file path"
  type        = string
  default     = "../app/lambda/bot.py"
}

variable "lambda_zip_path" {
  description = "Lambda function zip file path"
  type        = string
  default     = "../app/lambda/bot.zip"
}

##############################
# AWS API Gateway
##############################
variable "apigw_path" {
  description = "API Gateway path"
  type        = string
  default     = "chatbot"
}

##############################
# AWS S3 web
##############################
variable "web_dir" {
  description = "Web files path"
  type        = string
  default     = "../app/web/"
}

##############################
# AWS Cloudfront
##############################
variable "acm_cert_arn" {
  description = "ACM Certificate arn"
  type        = string
}

# ########################################
# Cloudflare
# ########################################
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone id"
  type        = string
}






