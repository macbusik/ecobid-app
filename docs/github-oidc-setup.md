# GitHub OIDC Setup for AWS

This guide explains how to set up GitHub Actions to authenticate with AWS using OIDC (OpenID Connect) instead of long-lived access keys.

## Benefits of OIDC

- ✅ No long-lived credentials stored in GitHub
- ✅ Automatic credential rotation
- ✅ Fine-grained permissions per workflow
- ✅ Better security posture
- ✅ Audit trail in CloudTrail

## Setup Steps

### 1. Create OIDC Identity Provider in AWS

```bash
# Get GitHub's OIDC thumbprint
THUMBPRINT="6938fd4d98bab03faadb97b34396831e3780aea1"

# Create OIDC provider
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "$THUMBPRINT" \
  --region eu-central-1
```

### 2. Create IAM Role for GitHub Actions

Save this as `github-actions-role.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_USERNAME/ecobid-app:*"
        }
      }
    }
  ]
}
```

Create the role:

```bash
# Replace YOUR_ACCOUNT_ID and YOUR_GITHUB_USERNAME
aws iam create-role \
  --role-name GitHubActionsEcoBidRole \
  --assume-role-policy-document file://github-actions-role.json \
  --description "Role for GitHub Actions to deploy EcoBid infrastructure"
```

### 3. Attach Permissions Policy

Create `github-actions-policy.json`:

```json
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
```

Attach the policy:

```bash
aws iam put-role-policy \
  --role-name GitHubActionsEcoBidRole \
  --policy-name EcoBidDeploymentPolicy \
  --policy-document file://github-actions-policy.json
```

### 4. Add Role ARN to GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `AWS_ROLE_ARN`
5. Value: `arn:aws:iam::YOUR_ACCOUNT_ID:role/GitHubActionsEcoBidRole`

### 5. Verify Setup

The workflow will now use OIDC authentication:

```yaml
- name: Configure AWS Credentials (OIDC)
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: eu-central-1
```

## Quick Setup Script

Save this as `setup-github-oidc.sh`:

```bash
#!/bin/bash

set -e

# Configuration
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
GITHUB_USERNAME="YOUR_GITHUB_USERNAME"
REPO_NAME="ecobid-app"
ROLE_NAME="GitHubActionsEcoBidRole"

echo "Setting up GitHub OIDC for AWS..."
echo "Account ID: $ACCOUNT_ID"
echo "Repository: $GITHUB_USERNAME/$REPO_NAME"

# 1. Create OIDC Provider (if not exists)
echo "Creating OIDC provider..."
aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "6938fd4d98bab03faadb97b34396831e3780aea1" \
  2>/dev/null || echo "OIDC provider already exists"

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
  --description "Role for GitHub Actions to deploy EcoBid infrastructure"

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

# 6. Get Role ARN
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.Arn' --output text)

echo ""
echo "✅ Setup complete!"
echo ""
echo "Add this to GitHub Secrets:"
echo "Name: AWS_ROLE_ARN"
echo "Value: $ROLE_ARN"
echo ""
echo "Go to: https://github.com/$GITHUB_USERNAME/$REPO_NAME/settings/secrets/actions"
```

Make it executable and run:

```bash
chmod +x setup-github-oidc.sh
./setup-github-oidc.sh
```

## Testing

Push a change to the `develop` branch and check the Actions tab. The workflow should:

1. ✅ Authenticate using OIDC
2. ✅ Assume the IAM role
3. ✅ Run Terraform commands
4. ✅ No access keys needed!

## Troubleshooting

### Error: "Not authorized to perform sts:AssumeRoleWithWebIdentity"

The trust policy needs to be updated. Run:

```bash
./scripts/update-oidc-trust.sh YOUR_GITHUB_USERNAME
```

Or manually update the trust policy:

1. Go to IAM → Roles → GitHubActionsEcoBidRole
2. Click "Trust relationships" tab
3. Click "Edit trust policy"
4. Ensure it matches:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_USERNAME/ecobid-app:*"
        }
      }
    }
  ]
}
```

**Important**: Replace `YOUR_ACCOUNT_ID` and `YOUR_USERNAME` with actual values.

### Error: "Access Denied" during Terraform

The IAM role needs more permissions. Update the policy:

```bash
aws iam put-role-policy \
  --role-name GitHubActionsEcoBidRole \
  --policy-name EcoBidDeploymentPolicy \
  --policy-document file://github-actions-policy.json
```

## Security Best Practices

1. **Limit to specific branches**:
   ```json
   "StringLike": {
     "token.actions.githubusercontent.com:sub": "repo:user/repo:ref:refs/heads/main"
   }
   ```

2. **Use separate roles for dev/prod**:
   - `GitHubActionsEcoBidDevRole` for develop branch
   - `GitHubActionsEcoBidProdRole` for main branch

3. **Enable CloudTrail** to audit all actions

4. **Review permissions regularly** - use least privilege

## References

- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [AWS IAM OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
