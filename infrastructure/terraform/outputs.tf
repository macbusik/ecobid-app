output "test_bucket_name" {
  description = "Name of the test S3 bucket"
  value       = module.test_bucket.bucket_name
}

output "test_bucket_arn" {
  description = "ARN of the test S3 bucket"
  value       = module.test_bucket.bucket_arn
}

output "items_table_name" {
  description = "Name of the items DynamoDB table"
  value       = module.items_table.table_name
}

output "items_table_arn" {
  description = "ARN of the items DynamoDB table"
  value       = module.items_table.table_arn
}

output "items_table_stream_arn" {
  description = "ARN of the items table stream"
  value       = module.items_table.stream_arn
}

output "images_bucket_name" {
  description = "Name of the images S3 bucket"
  value       = module.images_bucket.bucket_name
}

output "images_bucket_arn" {
  description = "ARN of the images S3 bucket"
  value       = module.images_bucket.bucket_arn
}

output "user_pool_id" {
  description = "ID of the Cognito user pool"
  value       = module.user_pool.user_pool_id
}

output "user_pool_arn" {
  description = "ARN of the Cognito user pool"
  value       = module.user_pool.user_pool_arn
}

output "user_pool_client_id" {
  description = "ID of the Cognito user pool client"
  value       = module.user_pool.client_id
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api.api_endpoint
}

output "api_handler_function_name" {
  description = "Name of the API handler Lambda function"
  value       = module.api_handler.function_name
}

output "event_bus_name" {
  description = "Name of the EventBridge event bus"
  value       = module.events.event_bus_name
}
