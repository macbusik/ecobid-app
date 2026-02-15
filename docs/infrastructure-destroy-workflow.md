# Infrastructure Destroy Workflow

## Context

Restructuring project to follow spec-driven development principles. Current infrastructure was deployed as Phase 1 proof-of-concept. Need to safely destroy and rebuild according to refined specifications.

## Current Deployed Infrastructure

**Environment**: Production (ecobid-prod)  
**Region**: eu-central-1  
**Deployed**: February 13, 2026

### Resources to Destroy

1. **DynamoDB Table**: ecobid-prod-items
   - Single-table design with GSI1, GSI2
   - Streams enabled
   - Point-in-time recovery enabled
   - **Data**: Minimal/none (test deployment)

2. **S3 Bucket**: ecobid-prod-images
   - Encrypted, versioned
   - **Data**: Minimal/none (test deployment)

3. **Cognito User Pool**: ecobid-prod-users
   - Custom attributes (location, rating)
   - **Users**: None (test deployment)

4. **Lambda Function**: ecobid-prod-api-handler
   - Placeholder function
   - **No production traffic**

5. **API Gateway**: ecobid-prod-api
   - REST API with Cognito authorizer
   - **No production traffic**

6. **EventBridge**: ecobid-prod-events
   - Custom event bus
   - **No active rules**

## Pre-Destroy Checklist

### ✅ Safety Checks
- [ ] Verify no production users (Cognito user count = 0)
- [ ] Verify no production data (DynamoDB item count = 0)
- [ ] Verify no uploaded images (S3 object count = 0)
- [ ] Confirm no active API traffic (CloudWatch metrics)
- [ ] Backup Terraform state file
- [ ] Document current resource ARNs (for reference)

### ✅ Documentation
- [ ] Update aws-architecture.md (mark as destroyed)
- [ ] Update submission-checklist.md (infrastructure status)
- [ ] Create ADR for restructuring decision
- [ ] Document lessons learned

## Destroy Workflow

### Option 1: Terraform Destroy (Recommended)

**Advantages**:
- Clean, automated removal
- Respects resource dependencies
- Tracked in Terraform state
- Can be version controlled

**Steps**:

```bash
# 1. Navigate to Terraform directory
cd infrastructure/terraform

# 2. Initialize Terraform (if needed)
terraform init

# 3. Review what will be destroyed
terraform plan -destroy

# 4. Destroy infrastructure
terraform destroy

# Confirm with: yes
```

**Expected Output**:
```
Plan: 0 to add, 0 to change, 15 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

...

Destroy complete! Resources: 15 destroyed.
```

### Option 2: Manual AWS Console Deletion

**Use only if Terraform destroy fails**

**Order of deletion** (respect dependencies):

1. **API Gateway** (no dependencies)
   ```bash
   aws apigateway delete-rest-api --rest-api-id <api-id> --region eu-central-1
   ```

2. **Lambda Function** (no dependencies)
   ```bash
   aws lambda delete-function --function-name ecobid-prod-api-handler --region eu-central-1
   ```

3. **EventBridge Event Bus** (no dependencies)
   ```bash
   aws events delete-event-bus --name ecobid-prod-events --region eu-central-1
   ```

4. **DynamoDB Table** (no dependencies)
   ```bash
   aws dynamodb delete-table --table-name ecobid-prod-items --region eu-central-1
   ```

5. **S3 Bucket** (must be empty first)
   ```bash
   # Empty bucket first
   aws s3 rm s3://ecobid-prod-images --recursive --region eu-central-1
   
   # Delete bucket
   aws s3api delete-bucket --bucket ecobid-prod-images --region eu-central-1
   ```

6. **Cognito User Pool** (delete users first if any)
   ```bash
   aws cognito-idp delete-user-pool --user-pool-id <pool-id> --region eu-central-1
   ```

### Option 3: Selective Destruction

**Keep some resources, destroy others**

Example: Keep DynamoDB and S3, destroy Lambda/API Gateway:

```bash
# Destroy specific resources
terraform destroy -target=module.api_handler
terraform destroy -target=module.api
terraform destroy -target=module.events
```

## Post-Destroy Actions

### 1. Verify Destruction
```bash
# Check DynamoDB tables
aws dynamodb list-tables --region eu-central-1 | grep ecobid

# Check S3 buckets
aws s3 ls | grep ecobid

# Check Lambda functions
aws lambda list-functions --region eu-central-1 | grep ecobid

# Check Cognito user pools
aws cognito-idp list-user-pools --max-results 10 --region eu-central-1 | grep ecobid
```

### 2. Update Documentation
- [ ] Update docs/aws-architecture.md (add "Destroyed" section)
- [ ] Update docs/submission-checklist.md (infrastructure: 0%)
- [ ] Update .sessions/YYYY-MM-DD.md (document destruction)
- [ ] Commit changes to git

### 3. Clean Up Terraform State
```bash
# Verify state is clean
terraform state list

# Should return empty or only bootstrap resources
```

### 4. Update CI/CD
- [ ] Disable GitHub Actions workflow (optional)
- [ ] Or keep for future deployments

## Cost Verification

After destruction, verify no ongoing costs:

```bash
# Check AWS Cost Explorer
aws ce get-cost-and-usage \
  --time-period Start=2026-02-15,End=2026-02-16 \
  --granularity DAILY \
  --metrics BlendedCost \
  --region eu-central-1
```

Expected: $0.00 (all resources were Free Tier)

## Restructuring Plan

### Phase 1: Spec Refinement
- [ ] Review and update all specs
- [ ] Define clear API contracts
- [ ] Design data models
- [ ] Plan infrastructure architecture

### Phase 2: Infrastructure as Code
- [ ] Refactor Terraform modules
- [ ] Implement spec-driven resource definitions
- [ ] Add comprehensive testing
- [ ] Document all decisions

### Phase 3: Deployment
- [ ] Deploy to dev environment first
- [ ] Validate against specs
- [ ] Deploy to production
- [ ] Update documentation

## Rollback Plan

If destruction causes issues:

1. **Terraform state backup** is in S3: ecobid-terraform-state
2. **Can recreate** from existing Terraform code
3. **No data loss** (no production data exists)

## Timeline

**Estimated Time**: 15-30 minutes

- Terraform destroy: 5-10 minutes
- Verification: 5 minutes
- Documentation updates: 10-15 minutes

## Decision Record

Create ADR-004 to document this decision:

```markdown
# ADR-004: Infrastructure Restructuring

**Date**: 2026-02-15
**Status**: Accepted

## Context
Initial infrastructure was deployed as proof-of-concept. 
Adopting spec-driven development requires restructuring.

## Decision
Destroy current infrastructure and rebuild according to refined specs.

## Consequences
- Clean slate for spec-driven approach
- No data loss (test deployment only)
- Opportunity to improve architecture
- Demonstrates iterative development for competition
```

## Notes

- All current infrastructure is test/development only
- No production users or data
- Safe to destroy and rebuild
- Good opportunity to demonstrate spec-driven approach
- Shows iterative development process for competition judges

## References

- Current Architecture: docs/aws-architecture.md
- Terraform Code: infrastructure/terraform/
- Submission Checklist: docs/submission-checklist.md
