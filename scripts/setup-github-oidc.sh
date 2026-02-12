#!/bin/bash

set -e

# Configuration
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
GITHUB_USERNAME="${1:-YOUR_GITHUB_USERNAME}"
REPO_NAME="ecobid-app"
ROLE_NAME="GitHubActionsEcoBidRole"

if [ "$GITHUB_USERNAME" = "YOUR_GITHUB_USERNAME" ]; then
  echo "Usage: $0 <github-username>"
  echo "Example: $0 macbusik"
  exit 1
fi

echo "Setting up GitHub OIDC for AWS..."
echo "Account ID: $ACCOUNT_ID"
echo "Repository: $GITHUB_USERNAME/$REPO_NAME"
echo ""

# 1. Create OIDC Provider (if not exists)
echo "Creating OIDC provider..."
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1" \
  2>/dev/null && echo "✓ OIDC provider created" || echo "✓ OIDC provider already exists"

# 2. Create Trust Policy
cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_USERNAME}/${REPO_NAME}:*"
        }
      }
    }
  ]
}
EOF

# 3. Create IAM Role
echo "Creating IAM role..."
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document file:///tmp/trust-policy.json \
  --description "Role for GitHub Actions to deploy EcoBid infrastructure" \
  && echo "✓ IAM role created" || echo "✓ IAM role already exists"

# 4. Create Permissions Policy
cat > /tmp/permissions-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:*",
        "s3:*",
        "cognito-idp:*",
        "lambda:*",
        "apigateway:*",
        "events:*",
        "iam:GetRole",
        "iam:GetRolePolicy",
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:PassRole",
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF

# 5. Attach Policy
echo "Attaching permissions policy..."
aws iam put-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "EcoBidDeploymentPolicy" \
  --policy-document file:///tmp/permissions-policy.json
echo "✓ Permissions policy attached"

# 6. Get Role ARN
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)

echo ""
echo "=========================================="
echo "✅ Setup complete!"
echo "=========================================="
echo ""
echo "Add this to GitHub Secrets:"
echo ""
echo "  Name:  AWS_ROLE_ARN"
echo "  Value: $ROLE_ARN"
echo ""
echo "Go to: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions"
echo ""
