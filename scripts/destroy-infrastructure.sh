#!/bin/bash

set -e

export TZ="Europe/Warsaw"

echo "=========================================="
echo "EcoBid Infrastructure Destruction Script"
echo "=========================================="
echo ""
echo "⚠️  WARNING: This will destroy all AWS resources!"
echo ""
echo "Current infrastructure:"
echo "  - DynamoDB: ecobid-prod-items"
echo "  - S3: ecobid-prod-images"
echo "  - Cognito: ecobid-prod-users"
echo "  - Lambda: ecobid-prod-api-handler"
echo "  - API Gateway: ecobid-prod-api"
echo "  - EventBridge: ecobid-prod-events"
echo ""
echo "Region: eu-central-1"
echo ""

# Safety check
read -p "Are you sure you want to destroy all infrastructure? (type 'yes' to confirm): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Destruction cancelled"
    exit 1
fi

echo ""
echo "Step 1: Pre-destruction verification..."
echo "=========================================="

# Check for users in Cognito
echo "Checking Cognito user pools..."
USER_POOLS=$(aws cognito-idp list-user-pools --max-results 10 --region eu-central-1 --query 'UserPools[?contains(Name, `ecobid`)].Id' --output text)

if [ -n "$USER_POOLS" ]; then
    for POOL_ID in $USER_POOLS; do
        USER_COUNT=$(aws cognito-idp list-users --user-pool-id "$POOL_ID" --region eu-central-1 --query 'length(Users)' --output text)
        echo "  User pool $POOL_ID: $USER_COUNT users"
        
        if [ "$USER_COUNT" -gt 0 ]; then
            echo "  ⚠️  Warning: User pool has $USER_COUNT users"
        fi
    done
else
    echo "  ✓ No Cognito user pools found"
fi

# Check for items in DynamoDB
echo "Checking DynamoDB tables..."
TABLES=$(aws dynamodb list-tables --region eu-central-1 --query 'TableNames[?contains(@, `ecobid`)]' --output text)

if [ -n "$TABLES" ]; then
    for TABLE in $TABLES; do
        ITEM_COUNT=$(aws dynamodb describe-table --table-name "$TABLE" --region eu-central-1 --query 'Table.ItemCount' --output text)
        echo "  Table $TABLE: $ITEM_COUNT items"
        
        if [ "$ITEM_COUNT" -gt 0 ]; then
            echo "  ⚠️  Warning: Table has $ITEM_COUNT items"
        fi
    done
else
    echo "  ✓ No DynamoDB tables found"
fi

# Check for objects in S3
echo "Checking S3 buckets..."
BUCKETS=$(aws s3 ls | grep ecobid | awk '{print $3}')

if [ -n "$BUCKETS" ]; then
    for BUCKET in $BUCKETS; do
        OBJECT_COUNT=$(aws s3 ls s3://$BUCKET --recursive --region eu-central-1 | wc -l)
        echo "  Bucket $BUCKET: $OBJECT_COUNT objects"
        
        if [ "$OBJECT_COUNT" -gt 0 ]; then
            echo "  ⚠️  Warning: Bucket has $OBJECT_COUNT objects"
        fi
    done
else
    echo "  ✓ No S3 buckets found"
fi

echo ""
read -p "Continue with destruction? (type 'yes' to confirm): " CONFIRM2

if [ "$CONFIRM2" != "yes" ]; then
    echo "❌ Destruction cancelled"
    exit 1
fi

echo ""
echo "Step 2: Backing up Terraform state..."
echo "=========================================="

cd infrastructure/terraform

if [ -f terraform.tfstate ]; then
    BACKUP_FILE="terraform.tfstate.backup.$(date +%Y%m%d-%H%M%S)"
    cp terraform.tfstate "$BACKUP_FILE"
    echo "✓ State backed up to: $BACKUP_FILE"
else
    echo "ℹ️  No local state file (using remote backend)"
fi

echo ""
echo "Step 3: Running Terraform destroy..."
echo "=========================================="

# Initialize Terraform
terraform init

# Show destroy plan
echo ""
echo "Destroy plan:"
terraform plan -destroy

echo ""
read -p "Proceed with Terraform destroy? (type 'yes' to confirm): " CONFIRM3

if [ "$CONFIRM3" != "yes" ]; then
    echo "❌ Destruction cancelled"
    exit 1
fi

# Execute destroy
terraform destroy -auto-approve

echo ""
echo "Step 4: Post-destruction verification..."
echo "=========================================="

# Verify resources are gone
echo "Checking remaining resources..."

REMAINING_TABLES=$(aws dynamodb list-tables --region eu-central-1 --query 'TableNames[?contains(@, `ecobid`)]' --output text)
REMAINING_BUCKETS=$(aws s3 ls | grep ecobid | wc -l)
REMAINING_FUNCTIONS=$(aws lambda list-functions --region eu-central-1 --query 'Functions[?contains(FunctionName, `ecobid`)].FunctionName' --output text)

if [ -z "$REMAINING_TABLES" ] && [ "$REMAINING_BUCKETS" -eq 0 ] && [ -z "$REMAINING_FUNCTIONS" ]; then
    echo "✓ All resources successfully destroyed"
else
    echo "⚠️  Some resources may still exist:"
    [ -n "$REMAINING_TABLES" ] && echo "  - DynamoDB tables: $REMAINING_TABLES"
    [ "$REMAINING_BUCKETS" -gt 0 ] && echo "  - S3 buckets: $REMAINING_BUCKETS"
    [ -n "$REMAINING_FUNCTIONS" ] && echo "  - Lambda functions: $REMAINING_FUNCTIONS"
fi

echo ""
echo "Step 5: Updating documentation..."
echo "=========================================="

cd ../..

# Update session file
SESSION_FILE=".sessions/$(date +%Y-%m-%d).md"
if [ -f "$SESSION_FILE" ]; then
    echo "- Infrastructure destroyed: $(date)" >> "$SESSION_FILE"
    echo "✓ Session file updated"
fi

echo ""
echo "=========================================="
echo "✅ Infrastructure destruction complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review docs/infrastructure-destroy-workflow.md"
echo "2. Update docs/aws-architecture.md"
echo "3. Update docs/submission-checklist.md"
echo "4. Create ADR-004 for restructuring decision"
echo "5. Commit changes to git"
echo ""
echo "To rebuild infrastructure:"
echo "  cd infrastructure/terraform"
echo "  terraform plan"
echo "  terraform apply"
echo ""
