---
inclusion: fileMatch
fileMatchPattern: 'infrastructure/**/*.tf'
---

# Infrastructure Development Guidelines

## Terraform Standards

Reference: infrastructure/terraform/

### Module Structure
All infrastructure must use modular Terraform design:
- modules/dynamodb/ - DynamoDB tables
- modules/s3/ - S3 buckets
- modules/cognito/ - Cognito user pools
- modules/lambda/ - Lambda functions
- modules/api_gateway/ - API Gateway
- modules/eventbridge/ - EventBridge

### Naming Convention
All resources use prefix: ${var.project_name}-${var.environment}
Example: ecobid-prod-items, ecobid-prod-images

### Required Tags
```hcl
tags = {
  Project     = "EcoBid"
  Environment = var.environment
  ManagedBy   = "Terraform"
  Competition = "10000AIdeas"
}
```

## AWS Free Tier Compliance

**CRITICAL**: All resources must stay within Free Tier limits

### DynamoDB
- Billing: On-demand (starts free)
- Storage: < 25GB
- RCU/WCU: < 25 each
- Streams: Enabled (included)
- PITR: Enabled (included)

### S3
- Storage: < 5GB
- GET: < 20,000/month
- PUT: < 2,000/month
- Encryption: SSE-S3 (free)
- Versioning: Enabled

### Lambda
- Requests: < 1M/month
- Compute: < 400K GB-seconds/month
- Memory: 128-512MB (optimize)
- Timeout: 30s max

### API Gateway
- Requests: < 1M/month
- Type: REST API
- Caching: Disabled (not free)

### Cognito
- MAUs: < 50,000
- MFA: Optional (SMS costs money)

## Deployment Workflow

### CI/CD Pipeline
GitHub Actions: .github/workflows/terraform.yml

Stages:
1. Validate - Format check, validation
2. Plan - Generate execution plan
3. Apply - Deploy (main branch only)

### State Management
- Backend: S3 (ecobid-terraform-state)
- Locking: DynamoDB
- Encryption: Enabled

## Security Requirements

### IAM Roles
- Least privilege permissions
- No wildcard (*) permissions
- Service-specific roles
- No hardcoded credentials

### Encryption
- DynamoDB: AWS managed keys
- S3: SSE-S3
- Secrets: AWS Secrets Manager (future)

### Network
- API Gateway: HTTPS only
- Lambda: VPC isolation (future)
- S3: Block public access

## Monitoring

### CloudWatch
- Lambda logs (7 days retention)
- Custom metrics
- Alarms for errors

### Cost Monitoring
- AWS Cost Explorer
- Budget alerts ($5, $10, $20)
- Daily usage checks

## Before Deploying

- [ ] Review Free Tier limits
- [ ] Check resource naming
- [ ] Verify tags
- [ ] Run terraform plan
- [ ] Review security settings
- [ ] Document in aws-architecture.md
