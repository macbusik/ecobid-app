variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for the table"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the table"
  type        = map(string)
  default     = {}
}
