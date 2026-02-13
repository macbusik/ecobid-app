variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "ARN of the Cognito user pool for authorization"
  type        = string
}

variable "lambda_functions" {
  description = "Map of route keys to Lambda function invoke ARNs"
  type = map(object({
    invoke_arn    = string
    function_name = string
  }))
}

variable "tags" {
  description = "Tags to apply to the API Gateway"
  type        = map(string)
  default     = {}
}
