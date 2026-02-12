output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "s3_images_bucket" {
  description = "S3 bucket for images"
  value       = module.s3.images_bucket_name
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.api_gateway.api_url
}
