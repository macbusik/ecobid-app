# MCP Servers Setup for EcoBid

## Recommended MCP Servers

Based on competition requirements and project needs, we'll use these AWS MCP servers:

### 1. AWS Knowledge MCP Server (ESSENTIAL)
**Why**: Remote, fully-managed access to latest AWS docs, API references, What's New, Well-Architected guidance
**Use for**: Learning AWS services, best practices, architecture decisions
**URL**: `https://knowledge-mcp.global.api.aws`

### 2. AWS Pricing MCP Server (ESSENTIAL)
**Why**: Competition requires Free Tier compliance and cost awareness
**Use for**: Estimating costs, staying within Free Tier limits
**Package**: `awslabs.aws-pricing-mcp-server@latest`

### 3. AWS Serverless MCP Server (RECOMMENDED)
**Why**: Complete serverless application lifecycle with SAM CLI
**Use for**: Lambda functions, API Gateway, DynamoDB setup
**Package**: `awslabs.aws-serverless-mcp-server@latest`

### 4. AWS IaC MCP Server (RECOMMENDED)
**Why**: CloudFormation + CDK best practices, security validation
**Use for**: Infrastructure as Code development
**Package**: `awslabs.aws-iac-mcp-server@latest`

### 5. Well-Architected Security MCP Server (OPTIONAL)
**Why**: Security best practices assessment
**Use for**: Security validation before submission
**Package**: `awslabs.well-architected-security-mcp-server@latest`

## Installation

### Prerequisites
```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install Python 3.10+
uv python install 3.10
```

### Kiro Configuration

Create/update `~/.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "aws-knowledge-mcp": {
      "url": "https://knowledge-mcp.global.api.aws"
    },
    "awslabs.aws-pricing-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-pricing-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_REGION": "us-east-1"
      }
    },
    "awslabs.aws-serverless-mcp-server": {
      "command": "uvx",
      "args": [
        "awslabs.aws-serverless-mcp-server@latest",
        "--allow-write",
        "--allow-sensitive-data-access"
      ],
      "env": {
        "AWS_REGION": "us-east-1"
      }
    },
    "awslabs.aws-iac-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-iac-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_REGION": "us-east-1"
      }
    }
  }
}
```

## Usage Examples

### With AWS Knowledge Server
```
"Using AWS Knowledge MCP, what are the best practices for DynamoDB table design?"
"Show me the latest Lambda pricing for us-east-1"
```

### With Pricing Server
```
"Using AWS Pricing MCP, estimate monthly costs for:
- 1M Lambda invocations
- 5GB DynamoDB storage
- 1M API Gateway requests"
```

### With Serverless Server
```
"Using AWS Serverless MCP, create a SAM template for a REST API with:
- Lambda function for bidding
- DynamoDB table for products
- API Gateway endpoints"
```

### With IaC Server
```
"Using AWS IaC MCP, generate CDK code for:
- Cognito user pool
- S3 bucket for images
- CloudFront distribution"
```

## Logging MCP Usage

Every time you use an MCP server, log it:
```bash
./scripts/kiro-log.sh log "MCP Usage" "Used AWS Knowledge MCP to research DynamoDB best practices"
./scripts/kiro-log.sh log "MCP Usage" "Used Pricing MCP to estimate Lambda costs"
```

## Competition Compliance

These MCP servers help meet TR-1 requirements:
- ✅ Use Kiro for portion of development
- ✅ Document Kiro implementation
- ✅ Provide detailed documentation

All MCP interactions are logged in:
- `docs/kiro-logs/YYYY-MM-DD.log` (timestamped)
- `docs/kiro-usage.md` (comprehensive documentation)

## Troubleshooting

### MCP Server Not Found
```bash
# Verify uv installation
uv --version

# Test server installation
uvx awslabs.aws-pricing-mcp-server@latest --help
```

### AWS Credentials
```bash
# Configure AWS CLI (if not already done)
aws configure

# Test credentials
aws sts get-caller-identity
```

### Connection Issues
- Check internet connection for remote servers (Knowledge MCP)
- Verify AWS credentials for local servers
- Check Kiro logs: `~/.kiro/logs/`

## Next Steps

1. Install MCP servers
2. Test each server with simple queries
3. Log all interactions
4. Use for actual development tasks
5. Document learnings in session notes
