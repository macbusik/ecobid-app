# Example: Simple S3 bucket for testing
module "test_bucket" {
  source = "./modules/s3"

  bucket_name = "${local.name_prefix}-test-bucket"
  tags        = local.common_tags
}

