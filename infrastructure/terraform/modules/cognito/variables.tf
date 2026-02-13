variable "user_pool_name" {
  description = "Name of the Cognito user pool"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the user pool"
  type        = map(string)
  default     = {}
}
