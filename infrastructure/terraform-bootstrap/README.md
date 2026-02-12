# Bootstrap Infrastructure for Terraform State

This directory contains the bootstrap infrastructure needed before the main Terraform can run.

## What This Creates

1. **S3 Bucket** - Stores Terraform state files
2. **DynamoDB Table** - Provides state locking

## One-Time Setup

This bootstrap infrastructure must be created **once** before the main Terraform can use remote state.

### Option 1: Deploy via GitHub Actions (Recommended)

1. Push this code to GitHub
2. GitHub Actions will automatically create the bootstrap resources
3. After successful deployment, the main Terraform can use the remote backend

### Option 2: Deploy Locally

```bash
cd infrastructure/terraform-bootstrap
terraform init
terraform apply
```

## After Bootstrap

Once the bootstrap resources exist:
1. Main Terraform in `infrastructure/terraform/` can use the S3 backend
2. State will be stored remotely
3. Multiple team members can collaborate safely

## Important Notes

- Bootstrap uses **local state** (stored in this directory)
- Main Terraform uses **remote state** (stored in S3)
- Don't delete the bootstrap resources while main infrastructure exists
- Bootstrap state file should be committed to git (it's just the bucket/table metadata)
