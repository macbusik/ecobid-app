module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment  = var.environment
}

module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

module "cognito" {
  source = "./modules/cognito"

  project_name = var.project_name
  environment  = var.environment
}

module "lambda" {
  source = "./modules/lambda"

  project_name       = var.project_name
  environment        = var.environment
  dynamodb_table_arn = module.dynamodb.table_arn
  images_bucket_arn  = module.s3.images_bucket_arn
}

module "api_gateway" {
  source = "./modules/api_gateway"

  project_name           = var.project_name
  environment            = var.environment
  lambda_invoke_arns     = module.lambda.function_invoke_arns
  cognito_user_pool_arn  = module.cognito.user_pool_arn
}

module "eventbridge" {
  source = "./modules/eventbridge"

  project_name         = var.project_name
  environment          = var.environment
  lambda_function_arns = module.lambda.function_arns
}
