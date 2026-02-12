terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Bootstrap uses local state
  # After this runs, main Terraform can use remote state
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "EcoBid"
      Environment = "bootstrap"
      ManagedBy   = "Terraform"
      Purpose     = "State Backend"
    }
  }
}
