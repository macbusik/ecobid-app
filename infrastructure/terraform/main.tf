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

