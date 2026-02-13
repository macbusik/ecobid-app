locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Competition = "10000AIdeas"
  }

  name_prefix = "${var.project_name}-${var.environment}"
  
  # Trigger pipeline test
}
