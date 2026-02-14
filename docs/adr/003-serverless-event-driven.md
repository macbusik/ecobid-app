# ADR-003: Serverless Event-Driven Architecture

**Date**: 2026-02-13  
**Status**: Accepted

## Context

EcoBid requires an architecture that:
- Scales automatically from 0 to 10,000+ users
- Stays within AWS Free Tier during development
- Handles real-time workflows (reservations, auctions, notifications)
- Supports asynchronous processing (image processing, notifications)
- Minimizes operational overhead (no servers to manage)
- Enables rapid development and deployment

### Architectural Patterns Considered

**Option 1: Traditional Monolith (EC2 + RDS)**
- Single application server on EC2
- Relational database on RDS
- Pros: Simple, familiar, easy debugging
- Cons: Fixed capacity, manual scaling, not Free Tier friendly, single point of failure

**Option 2: Microservices (ECS + RDS)**
- Multiple containerized services
- Service mesh for communication
- Pros: Scalable, independent deployment
- Cons: Complex, expensive, operational overhead, overkill for MVP

**Option 3: Serverless Event-Driven (Lambda + DynamoDB + EventBridge)**
- Lambda functions for compute
- DynamoDB for data
- EventBridge for orchestration
- Pros: Auto-scaling, pay-per-use, Free Tier friendly, no servers
- Cons: Cold starts, distributed debugging, vendor lock-in

## Decision

We will use **Serverless Event-Driven Architecture** with the following components:

### Core Services

**Compute**: AWS Lambda
- Stateless functions
- Auto-scaling (0 to 1000+ concurrent)
- Pay per invocation
- Free Tier: 1M requests/month

**Database**: Amazon DynamoDB
- NoSQL, single-table design
- On-demand scaling
- DynamoDB Streams for change data capture
- Free Tier: 25GB, 25 RCU/WCU

**Orchestration**: Amazon EventBridge
- Custom event bus
- Event routing and filtering
- Scheduled events (cron)
- Free Tier: 1M events/month

**API**: Amazon API Gateway
- RESTful API
- Cognito authorization
- Request validation
- Free Tier: 1M requests/month

**Storage**: Amazon S3
- Image uploads
- Static assets
- Free Tier: 5GB, 20K GET, 2K PUT

**Auth**: Amazon Cognito
- User pools
- JWT tokens
- Free Tier: 50K MAUs

### Event Flow Architecture

```
User Action (Mobile App)
    ↓
API Gateway (REST API)
    ↓
Lambda (API Handler)
    ↓
DynamoDB (Write)
    ↓
DynamoDB Streams
    ↓
Lambda (Stream Processor)
    ↓
EventBridge (Custom Events)
    ↓
┌────────────────┬────────────────┬────────────────┐
↓                ↓                ↓                ↓
Lambda           Lambda           Lambda           Lambda
(Notify)         (Process)        (Index)          (Moderate)
    ↓                ↓                ↓                ↓
SNS              Step Functions   OpenSearch       Comprehend
```

### Event Types

**Domain Events**:
- `ItemCreated` - New item posted
- `ItemReserved` - Item reserved by user
- `ReservationConfirmed` - Seller confirmed pickup
- `ReservationCompleted` - Item picked up
- `AuctionCreated` - New auction started
- `BidPlaced` - Bid placed on auction
- `AuctionEnded` - Auction time expired
- `UserRated` - User received rating

**System Events**:
- `ImageUploaded` - Image uploaded to S3
- `ImageProcessed` - Image resized/moderated
- `NotificationSent` - Push notification delivered
- `ErrorOccurred` - System error logged

### Lambda Functions

**API Handlers** (Synchronous):
- `CreateItem` - POST /items
- `GetItems` - GET /items
- `ReserveItem` - POST /items/{id}/reserve
- `PlaceBid` - POST /auctions/{id}/bid
- `GetUser` - GET /users/me

**Event Processors** (Asynchronous):
- `ProcessNewItem` - Handle ItemCreated event
- `ProcessReservation` - Handle reservation workflow
- `ProcessImage` - Resize and moderate images
- `SendNotifications` - Send push notifications
- `EndAuction` - Close auction, select winner
- `CleanupExpired` - Remove old items (scheduled)

### EventBridge Rules

**Event-Driven Rules**:
```yaml
ItemCreatedRule:
  EventPattern:
    source: [ecobid.items]
    detail-type: [ItemCreated]
  Targets:
    - ProcessNewItem (Lambda)
    - NotifyNearbyUsers (Lambda)

ReservationCreatedRule:
  EventPattern:
    source: [ecobid.reservations]
    detail-type: [ReservationCreated]
  Targets:
    - NotifySeller (Lambda)
    - ScheduleExpiry (Lambda)
```

**Scheduled Rules**:
```yaml
DailyCleanup:
  Schedule: cron(0 2 * * ? *)  # 2 AM daily
  Target: CleanupExpired (Lambda)

AuctionEndCheck:
  Schedule: rate(1 minute)
  Target: CheckAuctionEnd (Lambda)
```

## Consequences

### Positive

✅ **Auto-Scaling**: Scales from 0 to 10,000+ users automatically  
✅ **Cost-Effective**: Pay only for what you use, Free Tier friendly  
✅ **No Servers**: No infrastructure to manage, patch, or monitor  
✅ **Event-Driven**: Loosely coupled, easy to add new features  
✅ **Resilient**: Built-in retries, dead letter queues  
✅ **Fast Development**: Focus on business logic, not infrastructure  
✅ **Real-Time**: DynamoDB Streams + EventBridge for instant updates

### Negative

⚠️ **Cold Starts**: Lambda functions may have 1-2s delay on first invocation  
⚠️ **Distributed Debugging**: Harder to trace requests across services  
⚠️ **Vendor Lock-In**: Tightly coupled to AWS services  
⚠️ **Complexity**: Event-driven patterns require careful design  
⚠️ **Testing**: Integration testing more complex than monolith

### Mitigation Strategies

**Cold Starts**:
- Keep functions warm with EventBridge ping (critical paths only)
- Optimize package size (< 10MB)
- Use provisioned concurrency for critical functions (if needed)

**Distributed Debugging**:
- AWS X-Ray for distributed tracing
- Correlation IDs in all logs
- Centralized logging with CloudWatch Insights

**Vendor Lock-In**:
- Abstract AWS services behind interfaces
- Use standard patterns (event sourcing, CQRS)
- Document all AWS-specific code

**Complexity**:
- Comprehensive documentation of event flows
- Event schema registry
- Automated testing of event handlers

**Testing**:
- Unit tests for business logic
- Integration tests with LocalStack
- E2E tests in dev environment

## Implementation Guidelines

### Lambda Best Practices

**Function Design**:
- Single responsibility per function
- Keep handlers thin (< 50 lines)
- Business logic in separate modules
- Environment variables for configuration

**Performance**:
- Optimize memory allocation (128MB-512MB)
- Minimize cold start time (< 1s)
- Reuse connections (DynamoDB, S3)
- Use Lambda layers for shared code

**Error Handling**:
- Try-catch all async operations
- Dead letter queues for failed events
- Exponential backoff for retries
- Idempotency for all operations

### Event Design

**Event Schema**:
```json
{
  "version": "1.0",
  "id": "uuid",
  "source": "ecobid.items",
  "detail-type": "ItemCreated",
  "time": "2026-02-13T10:30:00Z",
  "detail": {
    "itemId": "item_123",
    "userId": "user_456",
    "category": "furniture",
    "location": {
      "lat": 52.2297,
      "lon": 21.0122,
      "geohash": "u3qcnm"
    }
  }
}
```

**Event Versioning**:
- Include version in event schema
- Support multiple versions simultaneously
- Deprecate old versions gradually

**Event Ordering**:
- Use timestamps for ordering
- Handle out-of-order events gracefully
- Idempotency keys for duplicate prevention

### Monitoring & Observability

**CloudWatch Metrics**:
- Lambda invocations, errors, duration
- API Gateway requests, latency, errors
- DynamoDB throttling, consumed capacity
- EventBridge events published, matched

**CloudWatch Alarms**:
- Lambda error rate > 1%
- API Gateway 5xx > 0.5%
- DynamoDB throttling events
- EventBridge failed invocations

**X-Ray Tracing**:
- Enable on all Lambda functions
- Trace API Gateway requests
- Visualize service map
- Identify bottlenecks

## Cost Analysis

### Free Tier Limits (12 months)

| Service | Free Tier | Expected Usage | Status |
|---------|-----------|----------------|--------|
| Lambda Requests | 1M/month | < 100K/month | ✅ Safe |
| Lambda Compute | 400K GB-sec/month | < 50K GB-sec/month | ✅ Safe |
| API Gateway | 1M requests/month | < 100K/month | ✅ Safe |
| DynamoDB | 25 RCU/WCU | < 10 RCU/WCU | ✅ Safe |
| EventBridge | 1M events/month | < 50K/month | ✅ Safe |
| S3 Storage | 5GB | < 1GB | ✅ Safe |

### Cost Projection (After Free Tier)

**1,000 Users**:
- Lambda: $5/month
- DynamoDB: $10/month
- API Gateway: $3/month
- S3: $2/month
- **Total**: ~$20/month

**10,000 Users**:
- Lambda: $50/month
- DynamoDB: $100/month
- API Gateway: $30/month
- S3: $20/month
- **Total**: ~$200/month

## Security Considerations

**Authentication**:
- Cognito JWT tokens
- API Gateway authorizer
- Token expiry (1 hour)

**Authorization**:
- IAM roles for Lambda
- Least privilege permissions
- Resource-based policies

**Data Protection**:
- DynamoDB encryption at rest
- S3 encryption (SSE-S3)
- TLS 1.2+ in transit

**Input Validation**:
- API Gateway request validation
- Lambda input sanitization
- DynamoDB query parameterization

## Future Enhancements

### Phase 2
- [ ] Step Functions for complex workflows
- [ ] AppSync for real-time GraphQL
- [ ] Lambda@Edge for global distribution

### Phase 3
- [ ] Multi-region deployment
- [ ] Event replay capability
- [ ] Advanced monitoring with X-Ray

## References

- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [EventBridge Patterns](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)
- [Serverless Architectures](https://aws.amazon.com/serverless/)

## Related ADRs

- [ADR-001: Node.js Runtime](./001-nodejs-runtime.md)
- [ADR-002: DynamoDB Single-Table Design](./002-dynamodb-single-table.md)
- ADR-004: Cognito Authentication (planned)
