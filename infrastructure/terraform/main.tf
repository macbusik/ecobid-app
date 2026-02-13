# Example: Simple S3 bucket for testing
module "test_bucket" {
  source = "./modules/s3"

  bucket_name = "${local.name_prefix}-test-bucket"
  tags        = local.common_tags
}

# Main DynamoDB table for application data
module "items_table" {
  source = "./modules/dynamodb"

  table_name                    = "${local.name_prefix}-items"
  enable_point_in_time_recovery = true
  tags                          = local.common_tags
}

# S3 bucket for item images
module "images_bucket" {
  source = "./modules/s3"

  bucket_name       = "${local.name_prefix}-images"
  enable_versioning = true
  tags              = local.common_tags
}

# Cognito user pool for authentication
module "user_pool" {
  source = "./modules/cognito"

  user_pool_name = "${local.name_prefix}-users"
  tags           = local.common_tags
}

# Placeholder Lambda function
module "api_handler" {
  source = "./modules/lambda"

  function_name = "${local.name_prefix}-api-handler"
  source_dir    = "${path.root}/../../backend/src/handlers/placeholder"
  runtime       = "nodejs20.x"
  memory_size   = 128
  timeout       = 30

  environment_variables = {
    TABLE_NAME  = module.items_table.table_name
    BUCKET_NAME = module.images_bucket.bucket_name
  }

  tags = local.common_tags
}

# API Gateway
module "api" {
  source = "./modules/api_gateway"

  api_name              = "${local.name_prefix}-api"
  cognito_user_pool_arn = module.user_pool.user_pool_arn

  lambda_functions = {
    "api-handler" = {
      invoke_arn    = module.api_handler.invoke_arn
      function_name = module.api_handler.function_name
    }
  }

  tags = local.common_tags
}

# EventBridge
module "events" {
  source = "./modules/eventbridge"

  event_bus_name = "${local.name_prefix}-events"

  rules = {
    # Placeholder for future event rules
  }

  tags = local.common_tags
}

