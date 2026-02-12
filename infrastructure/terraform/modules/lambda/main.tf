# Placeholder for Lambda module - will be implemented with actual functions
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "dynamodb_table_arn" {
  type = string
}

variable "images_bucket_arn" {
  type = string
}

output "function_arns" {
  value = {}
}

output "function_invoke_arns" {
  value = {}
}
