#!/bin/bash

set -e

# Configuration
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
GITHUB_USERNAME="${1:-macbusik}"
REPO_NAME="ecobid-app"
ROLE_NAME="GitHubActionsEcoBidRole"

echo "Updating trust policy for GitHub OIDC..."
echo "Account ID: $ACCOUNT_ID"
echo "Repository: $GITHUB_USERNAME/$REPO_NAME"
echo ""

# Create updated trust policy
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

echo "Updating trust policy..."
aws iam update-assume-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-document file:///tmp/trust-policy.json

echo ""
echo "✅ Trust policy updated!"
echo ""
echo "Trust policy allows:"
echo "  - Repository: ${GITHUB_USERNAME}/${REPO_NAME}"
echo "  - All branches and tags"
echo ""
echo "Verify with:"
echo "  aws iam get-role --role-name $ROLE_NAME --query 'Role.AssumeRolePolicyDocument'"
