# Placeholder for EventBridge module
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "lambda_function_arns" {
  type = map(string)
}
