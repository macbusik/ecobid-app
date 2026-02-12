# Placeholder for API Gateway module
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_invoke_arns" {
  type = map(string)
}

variable "cognito_user_pool_arn" {
  type = string
}

output "api_url" {
  value = ""
}
