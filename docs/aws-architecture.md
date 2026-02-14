# AWS Architecture - EcoBid

## Overview

EcoBid uses a serverless, event-driven architecture on AWS, optimized for the Free Tier. All infrastructure is managed with Terraform and deployed via GitHub Actions CI/CD pipeline.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Mobile App (React Native)                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTPS
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Amazon API Gateway                          │
│                    (REST API + Cognito Auth)                     │
└────────────┬────────────────────────────────────────────────────┘
             │
             │ Invoke
             ↓
┌─────────────────────────────────────────────────────────────────┐
│                       AWS Lambda Functions                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ API Handler  │  │ Image Proc   │  │ Notifications│         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└────┬────────────────────┬────────────────────┬─────────────────┘
     │                    │                    │
     │ Read/Write         │ Process            │ Send
     ↓                    ↓                    ↓
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  DynamoDB   │    │     S3      │    │     SNS     │
│   Tables    │    │   Buckets   │    │   Topics    │
└─────┬───────┘    └─────────────┘    └─────────────┘
      │
      │ Streams
      ↓
┌─────────────────────────────────────────────────────────────────┐
│                      Amazon EventBridge                          │
│              (Event Bus + Scheduled Rules)                       │
└─────────────────────────────────────────────────────────────────┘
      │
      │ Trigger
      ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Event Processing Lambdas                      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      Amazon Cognito                              │
│                   (User Authentication)                          │
└─────────────────────────────────────────────────────────────────┘
```

## Deployed Infrastructure

### Current Status: Phase 1 Complete ✅

**Deployment Date**: February 13, 2026  
**Environment**: Production (ecobid-prod)  
**Region**: eu-central-1  
**Deployment Method**: Terraform + GitHub Actions OIDC

### Core Services

#### 1. Amazon DynamoDB
**Table**: `ecobid-prod-items`

**Purpose**: Primary database for all application data (items, users, reservations, auctions)

**Configuration**:
- Billing Mode: On-Demand (Free Tier: 25 RCU/WCU)
- Encryption: AWS managed keys (SSE)
- Point-in-Time Recovery: Enabled
- TTL: Enabled (automatic cleanup of expired items)
- Streams: Enabled (NEW_AND_OLD_IMAGES)

**Indexes**:
- GSI1: Location-based queries (geohash + timestamp)
- GSI2: Category queries (category + timestamp)

**Single-Table Design**:
```
PK                    SK                      Attributes
-------------------------------------------------------------------
USER#user_123         PROFILE                 username, email, rating
USER#user_123         ITEM#item_456           (user's items)
ITEM#item_456         METADATA                title, category, status
ITEM#item_456         RESERVATION#res_789     buyerId, status
GEO#u3qcnm            ITEM#item_456           (geohash index)
```

**Free Tier Compliance**:
- Storage: < 1GB (well within 25GB limit)
- Read/Write: Minimal usage (within 25 RCU/WCU)
- Streams: Included in Free Tier

#### 2. Amazon S3
**Bucket**: `ecobid-prod-images`

**Purpose**: Store item images uploaded by users

**Configuration**:
- Encryption: AES-256 (SSE-S3)
- Versioning: Enabled
- Public Access: Blocked (presigned URLs for access)
- Lifecycle Policy: Delete after 90 days (planned)

**Free Tier Compliance**:
- Storage: < 1GB (within 5GB limit)
- PUT Requests: < 100/day (within 2,000/month limit)
- GET Requests: < 500/day (within 20,000/month limit)

**Future**: CloudFront distribution for image delivery

#### 3. Amazon Cognito
**User Pool**: `ecobid-prod-users`

**Purpose**: User authentication and authorization

**Configuration**:
- Sign-in: Email + Password
- MFA: Optional (SMS or TOTP)
- Password Policy: Strong (min 8 chars, uppercase, lowercase, numbers)
- Custom Attributes:
  - `custom:location` - User's city/region
  - `custom:rating` - User rating (1-5 stars)

**App Client**:
- Auth flows: USER_PASSWORD_AUTH, REFRESH_TOKEN_AUTH
- Token expiry: Access (1 hour), Refresh (30 days)

**Free Tier Compliance**:
- MAUs: < 100 (within 50,000 limit)
- No charges for authentication operations

#### 4. AWS Lambda
**Function**: `ecobid-prod-api-handler`

**Purpose**: Placeholder API handler (to be replaced with actual handlers)

**Configuration**:
- Runtime: Node.js 20.x
- Memory: 128 MB
- Timeout: 30 seconds
- Architecture: x86_64
- Environment Variables:
  - `TABLE_NAME`: ecobid-prod-items
  - `BUCKET_NAME`: ecobid-prod-images

**IAM Role**: Managed by Terraform with least-privilege permissions
- DynamoDB: Read/Write to items table
- S3: Read/Write to images bucket
- CloudWatch: Logs

**Free Tier Compliance**:
- Requests: < 1,000/day (within 1M/month limit)
- Compute: < 10 GB-seconds/day (within 400,000 GB-seconds/month)

**Future Functions**:
- CreateItem, GetItems, ReserveItem
- PlaceBid, ConfirmPickup, RateUser
- ProcessImage, NotifyUsers, EndAuction

#### 5. Amazon API Gateway
**API**: `ecobid-prod-api`

**Purpose**: RESTful API for mobile app

**Configuration**:
- Type: REST API
- Authorization: Cognito User Pool
- CORS: Enabled
- Throttling: 1,000 requests/second (burst)
- Caching: Disabled (Free Tier)

**Endpoints** (Planned):
```
POST   /v1/items              - Create item
GET    /v1/items              - List items (with filters)
GET    /v1/items/{id}         - Get item details
POST   /v1/items/{id}/reserve - Reserve item
POST   /v1/auctions           - Create auction
POST   /v1/auctions/{id}/bid  - Place bid
```

**Integration**: Lambda proxy integration

**Free Tier Compliance**:
- Requests: < 30,000/day (within 1M/month limit)

#### 6. Amazon EventBridge
**Event Bus**: `ecobid-prod-events`

**Purpose**: Event-driven workflows and scheduled tasks

**Configuration**:
- Type: Custom event bus
- Archive: Disabled (Free Tier)
- Schema Registry: Disabled (Free Tier)

**Event Rules** (Planned):
- `ItemCreatedRule` - Notify nearby users
- `ReservationCreatedRule` - Start expiry timer
- `AuctionEndRule` - Close auction, select winner
- `DailyCleanupRule` - Remove old items (scheduled)

**Free Tier Compliance**:
- Events: < 1,000/day (within 1M/month limit)

### Supporting Services

#### 7. Amazon CloudWatch
**Purpose**: Logging, monitoring, and alarms

**Configuration**:
- Log Groups: One per Lambda function
- Retention: 7 days (Free Tier)
- Metrics: Lambda invocations, errors, duration
- Alarms: Error rate, throttling (planned)

**Free Tier Compliance**:
- Logs: < 1GB/month (within 5GB limit)
- Metrics: < 10 custom metrics (within 10 limit)

#### 8. AWS IAM
**Roles**:
- `ecobid-prod-api-handler-role` - Lambda execution role
- `GitHubActionsEcoBidRole` - CI/CD deployment role (OIDC)

**Policies**:
- Least-privilege access
- Service-specific permissions
- No wildcard permissions

### Infrastructure as Code

#### Terraform Configuration
**Location**: `infrastructure/terraform/`

**Structure**:
```
terraform/
├── main.tf              # Root module
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── providers.tf         # AWS provider config
├── backend.tf           # S3 backend config
├── locals.tf            # Local values
└── modules/
    ├── dynamodb/        # DynamoDB table module
    ├── s3/              # S3 bucket module
    ├── cognito/         # Cognito user pool module
    ├── lambda/          # Lambda function module
    ├── api_gateway/     # API Gateway module
    └── eventbridge/     # EventBridge module
```

**State Management**:
- Backend: S3 bucket (ecobid-terraform-state)
- State Locking: DynamoDB table
- Encryption: Enabled

**Modules**:
- Reusable, tested components
- Consistent naming conventions
- Comprehensive outputs

#### CI/CD Pipeline
**Platform**: GitHub Actions

**Workflow**: `.github/workflows/terraform.yml`

**Stages**:
1. **Validate** - Format check, validation
2. **Plan** - Generate execution plan
3. **Apply** - Deploy to production (main branch only)

**Authentication**: GitHub OIDC (no long-lived credentials)

**Triggers**:
- Push to `develop` or `main` (plan only)
- Pull request to `main` (plan + comment)
- Merge to `main` (plan + apply)

## AWS Service Limits & Monitoring

### Free Tier Limits

| Service | Free Tier Limit | Current Usage | Status |
|---------|----------------|---------------|--------|
| Lambda Requests | 1M/month | < 1K/month | ✅ Safe |
| Lambda Compute | 400K GB-sec/month | < 1K GB-sec/month | ✅ Safe |
| DynamoDB Storage | 25 GB | < 1 GB | ✅ Safe |
| DynamoDB RCU/WCU | 25 each | < 5 each | ✅ Safe |
| S3 Storage | 5 GB | < 1 GB | ✅ Safe |
| S3 GET Requests | 20K/month | < 1K/month | ✅ Safe |
| S3 PUT Requests | 2K/month | < 100/month | ✅ Safe |
| API Gateway | 1M requests/month | < 1K/month | ✅ Safe |
| Cognito MAUs | 50K | < 100 | ✅ Safe |

### Monitoring Strategy

**CloudWatch Alarms** (Planned):
- Lambda error rate > 1%
- API Gateway 5xx errors > 0.5%
- DynamoDB throttling events
- S3 upload failures

**Cost Monitoring**:
- AWS Cost Explorer (daily checks)
- Budget alerts ($5, $10, $20 thresholds)
- Free Tier usage tracking

**Performance Monitoring**:
- Lambda cold start duration
- API response times
- DynamoDB query latency

## Security Architecture

### Authentication & Authorization
- **User Auth**: Cognito User Pools
- **API Auth**: Cognito authorizer on API Gateway
- **Service Auth**: IAM roles with least privilege

### Data Protection
- **At Rest**: 
  - DynamoDB: AWS managed encryption
  - S3: SSE-S3 encryption
  - Secrets: AWS Secrets Manager (future)
- **In Transit**: 
  - HTTPS only (TLS 1.2+)
  - API Gateway enforces HTTPS

### Network Security
- **API Gateway**: Throttling, rate limiting
- **Lambda**: VPC isolation (future)
- **S3**: Bucket policies, no public access

### Compliance
- **GDPR**: User data deletion, data export
- **Privacy**: No PII in logs
- **Audit**: CloudTrail logging (future)

## Scalability & Performance

### Current Capacity
- **Users**: 10,000 concurrent
- **Items**: 100,000 in database
- **API Requests**: 1,000/second
- **Image Uploads**: 100/minute

### Scaling Strategy
- **Lambda**: Auto-scaling (up to 1,000 concurrent)
- **DynamoDB**: On-demand scaling
- **API Gateway**: Auto-scaling
- **S3**: Unlimited storage

### Performance Targets
- API response: < 500ms (p95)
- Lambda cold start: < 1s
- Image upload: < 3s
- Location search: < 500ms

## Disaster Recovery

### Backup Strategy
- **DynamoDB**: Point-in-time recovery (35 days)
- **S3**: Versioning enabled
- **Terraform State**: S3 versioning + replication (future)

### Recovery Objectives
- **RTO** (Recovery Time Objective): 1 hour
- **RPO** (Recovery Point Objective): 5 minutes

### Incident Response
1. CloudWatch alarm triggers
2. Investigate logs and metrics
3. Rollback via Terraform (if needed)
4. Post-mortem documentation

## Cost Optimization

### Current Costs
- **Monthly**: $0 (within Free Tier)
- **Projected (1K users)**: $0-5/month
- **Projected (10K users)**: $20-50/month

### Optimization Strategies
- Single-table DynamoDB design
- Image compression before upload
- Lambda memory optimization
- API Gateway caching (when needed)
- S3 lifecycle policies

## Future Enhancements

### Phase 2 (Months 4-6)
- [ ] CloudFront distribution for images
- [ ] AWS AppSync for real-time features
- [ ] Amazon Rekognition for image categorization
- [ ] Amazon Comprehend for content moderation
- [ ] Step Functions for complex workflows

### Phase 3 (Months 7-12)
- [ ] Amazon Location Service for geospatial queries
- [ ] Amazon SES for email notifications
- [ ] AWS WAF for API protection
- [ ] Amazon OpenSearch for advanced search
- [ ] Multi-region deployment

### Phase 4 (Months 12+)
- [ ] Amazon Bedrock for AI features
- [ ] AWS Amplify for frontend hosting
- [ ] Amazon Pinpoint for user engagement
- [ ] AWS X-Ray for distributed tracing
- [ ] Amazon QuickSight for analytics

## Architecture Decision Records

See `docs/adr/` for detailed architecture decisions:
- [ADR-001: Node.js Runtime](../docs/adr/001-nodejs-runtime.md)
- ADR-002: DynamoDB Single-Table Design (planned)
- ADR-003: Serverless Event-Driven Architecture (planned)
- ADR-004: Cognito for Authentication (planned)

## References

- [Terraform Configuration](../infrastructure/terraform/)
- [Event-Driven Architecture](../specs/architecture/event-driven-architecture.md)
- [Development Guidelines](./development-guidelines.md)
- [Competition Compliance](../specs/requirements/competition-compliance.md)

---

**Last Updated**: 2026-02-14  
**Infrastructure Version**: v0.1.0  
**Deployment Status**: Phase 1 Complete ✅
