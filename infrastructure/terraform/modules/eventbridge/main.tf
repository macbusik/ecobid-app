# Event Bus
resource "aws_cloudwatch_event_bus" "this" {
  name = var.event_bus_name
  tags = var.tags
}

# Event Rules
resource "aws_cloudwatch_event_rule" "rules" {
  for_each = var.rules

  name           = each.key
  description    = each.value.description
  event_bus_name = aws_cloudwatch_event_bus.this.name

  event_pattern       = each.value.event_pattern != "" ? each.value.event_pattern : null
  schedule_expression = each.value.schedule_expression

  tags = var.tags
}

# Event Targets
resource "aws_cloudwatch_event_target" "targets" {
  for_each = var.rules

  rule           = aws_cloudwatch_event_rule.rules[each.key].name
  event_bus_name = aws_cloudwatch_event_bus.this.name
  target_id      = "${each.key}-target"
  arn            = each.value.target_arn
}
