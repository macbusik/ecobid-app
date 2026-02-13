variable "event_bus_name" {
  description = "Name of the EventBridge event bus"
  type        = string
}

variable "rules" {
  description = "Map of EventBridge rules"
  type = map(object({
    description         = string
    event_pattern       = string
    schedule_expression = optional(string)
    target_arn          = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to EventBridge resources"
  type        = map(string)
  default     = {}
}
