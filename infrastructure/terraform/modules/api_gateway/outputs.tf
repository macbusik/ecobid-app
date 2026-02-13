output "api_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.this.arn
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "authorizer_id" {
  description = "ID of the Cognito authorizer"
  value       = aws_api_gateway_authorizer.cognito.id
}
