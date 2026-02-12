# Event-Driven Architecture - EcoBid

## Architecture Overview

EcoBid uses serverless, event-driven architecture on AWS to handle real-time workflows, notifications, and state transitions.

## Core Principles

1. **Event-driven**: State changes trigger events, not direct calls
2. **Loosely coupled**: Services communicate via events
3. **Scalable**: Auto-scaling Lambda functions
4. **Resilient**: Dead letter queues, retries, idempotency
5. **Observable**: CloudWatch logs, X-Ray tracing

## Event Sources

### 1. API Gateway (Synchronous)
- User actions (post item, reserve, bid)
- Returns immediate response
- Triggers Lambda functions

### 2. DynamoDB Streams (Asynchronous)
- Item state changes
- User profile updates
- Triggers downstream processing

### 3. EventBridge (Asynchronous)
- Business events (reservation created, auction ended)
- Scheduled events (auction expiry, reminder notifications)
- Cross-service communication

### 4. S3 Events
- Image uploaded
- Triggers image processing (resize, moderation)

### 5. SNS (Pub/Sub)
- Push notifications
- Email notifications
- SMS (future)

## Event Flows

### Flow 1: Post Free Item

```
User → API Gateway → Lambda (CreateItem)
                        ↓
                   DynamoDB (items table)
                        ↓
                   DynamoDB Stream
                        ↓
                   Lambda (ProcessNewItem)
                        ↓
                   EventBridge (ItemCreated event)
                        ↓
                   ┌────────────────┬─────────────────┐
                   ↓                ↓                 ↓
            Lambda (NotifyNearby)  Lambda (Index)   Lambda (Moderate)
                   ↓                ↓                 ↓
                  SNS          OpenSearch         Comprehend
                   ↓
            Push Notifications
```

### Flow 2: Reserve Item

```
User → API Gateway → Lambda (ReserveItem)
                        ↓
                   DynamoDB (update item status)
                        ↓
                   DynamoDB Stream
                        ↓
                   Lambda (ProcessReservation)
                        ↓
                   EventBridge (ReservationCreated)
                        ↓
                   ┌────────────────┬─────────────────┐
                   ↓                ↓                 ↓
         Lambda (NotifySeller)  Lambda (StartTimer)  Lambda (UpdateStats)
                   ↓                ↓
                  SNS          EventBridge (scheduled)
                   ↓                ↓ (24 hours later)
            Push Notification   Lambda (CancelExpired)
```

### Flow 3: Quick Auction Lifecycle

```
User → API Gateway → Lambda (CreateAuction)
                        ↓
                   DynamoDB (auctions table)
                        ↓
                   EventBridge (AuctionCreated)
                        ↓
                   Lambda (ScheduleAuctionEnd)
                        ↓
                   EventBridge (scheduled rule: auction end time)
                        ↓
                   Lambda (EndAuction)
                        ↓
                   ┌────────────────┬─────────────────┐
                   ↓                ↓                 ↓
         Lambda (NotifyWinner)  Lambda (NotifyLoser)  Lambda (UpdateStats)
                   ↓                ↓
                  SNS              SNS
```

### Flow 4: Image Upload & Processing

```
Mobile App → S3 (presigned URL upload)
                ↓
             S3 Event
                ↓
         Lambda (ProcessImage)
                ↓
         ┌──────────────┬──────────────┐
         ↓              ↓              ↓
    Rekognition    Lambda (Resize)  Comprehend
    (categorize)   (thumbnails)     (moderate)
         ↓              ↓              ↓
    DynamoDB       S3 (thumbs)    DynamoDB
    (category)                    (moderation)
```

## Event Schema

### ItemCreated
```json
{
  "eventType": "ItemCreated",
  "timestamp": "2026-02-12T16:30:00Z",
  "itemId": "item_123",
  "userId": "user_456",
  "category": "furniture",
  "location": {
    "lat": 52.2297,
    "lon": 21.0122,
    "geohash": "u3qcnm"
  },
  "mode": "free",
  "metadata": {
    "title": "IKEA desk",
    "imageUrl": "s3://bucket/item_123.jpg"
  }
}
```

### ReservationCreated
```json
{
  "eventType": "ReservationCreated",
  "timestamp": "2026-02-12T16:35:00Z",
  "reservationId": "res_789",
  "itemId": "item_123",
  "buyerId": "user_999",
  "sellerId": "user_456",
  "expiresAt": "2026-02-13T16:35:00Z"
}
```

### AuctionEnded
```json
{
  "eventType": "AuctionEnded",
  "timestamp": "2026-02-13T16:30:00Z",
  "auctionId": "auction_555",
  "itemId": "item_888",
  "winnerId": "user_777",
  "winningBid": 15.00,
  "totalBids": 8
}
```

## AWS Services

### Lambda Functions

**API Handlers**:
- `CreateItem` - Post new item
- `GetItems` - Search/browse items
- `ReserveItem` - Reserve free item
- `PlaceBid` - Bid on auction
- `ConfirmPickup` - Mark as picked up
- `RateUser` - Submit rating

**Event Processors**:
- `ProcessNewItem` - Handle new item events
- `ProcessReservation` - Handle reservation events
- `ProcessImage` - Image processing pipeline
- `NotifyUsers` - Send push notifications
- `EndAuction` - Close auction, select winner
- `CancelExpired` - Cancel expired reservations

### DynamoDB Tables

**Single-Table Design**:
```
PK                    SK                      Attributes
-------------------------------------------------------------------
USER#user_123         PROFILE                 username, email, rating
USER#user_123         ITEM#item_456           (user's items)
ITEM#item_456         METADATA                title, category, status, location
ITEM#item_456         RESERVATION#res_789     buyerId, status, timestamp
AUCTION#auction_555   METADATA                itemId, endTime, minBid
AUCTION#auction_555   BID#bid_999             userId, amount, timestamp
GEO#u3qcnm            ITEM#item_456           (geohash index)
```

**GSIs**:
- `GSI1`: Location-based queries (geohash + timestamp)
- `GSI2`: Category queries (category + timestamp)
- `GSI3`: User items (userId + status)

### EventBridge Rules

**Scheduled**:
- `AuctionEndRule` - Dynamic rules per auction
- `DailyCleanup` - Remove old completed items
- `ReminderNotifications` - Pickup reminders

**Event Patterns**:
- `ItemCreatedRule` - Route to notification service
- `ReservationCreatedRule` - Start expiry timer
- `AuctionEndedRule` - Process winner selection

### SNS Topics

- `UserNotifications` - Push notifications to mobile
- `EmailNotifications` - Email alerts
- `AdminAlerts` - System alerts

### S3 Buckets

- `ecobid-images` - Original uploads
- `ecobid-thumbnails` - Processed thumbnails
- `ecobid-backups` - Database backups

### Step Functions (Future)

**Complex Workflows**:
- Multi-step auction with auto-extend
- Dispute resolution workflow
- Bulk item posting

## Error Handling

### Dead Letter Queues (DLQ)
- All Lambda functions have DLQ
- Failed events sent to SQS
- Monitored via CloudWatch alarms

### Retry Strategy
- Exponential backoff
- Max 3 retries
- Idempotency keys for all operations

### Circuit Breaker
- Fail fast on downstream service errors
- Graceful degradation (e.g., skip notifications if SNS down)

## Observability

### CloudWatch
- Lambda logs
- Custom metrics (items posted, reservations, etc.)
- Alarms (error rate, latency)

### X-Ray
- Distributed tracing
- Performance bottleneck identification
- Service map visualization

### Dashboards
- Real-time metrics
- User activity
- System health

## Free Tier Optimization

### Lambda
- Keep functions warm (EventBridge ping)
- Minimize cold starts (provisioned concurrency for critical paths)
- Optimize memory allocation

### DynamoDB
- Single-table design (minimize RCU/WCU)
- On-demand billing initially
- Batch operations where possible

### S3
- Lifecycle policies (delete old images)
- Intelligent tiering
- CloudFront for image delivery

### EventBridge
- Consolidate events where possible
- Use filtering to reduce Lambda invocations

## Security

### IAM
- Least privilege per Lambda
- Service-to-service authentication
- No hardcoded credentials

### Encryption
- DynamoDB encryption at rest
- S3 encryption (SSE-S3)
- TLS in transit

### API Security
- Cognito authentication
- API Gateway throttling
- WAF rules (future)

## Scalability

### Auto-scaling
- Lambda: Automatic
- DynamoDB: On-demand or auto-scaling
- API Gateway: Automatic

### Caching
- API Gateway caching (GET requests)
- CloudFront for images
- DynamoDB DAX (future)

### Rate Limiting
- Per-user API limits
- Per-IP limits
- Burst protection

## Monitoring & Alerts

### Critical Alarms
- Lambda error rate > 1%
- API Gateway 5xx > 0.5%
- DynamoDB throttling
- S3 upload failures

### Business Metrics
- Items posted per hour
- Reservation rate
- Completion rate
- User growth

## Deployment

### CI/CD Pipeline
- GitHub Actions
- SAM/CDK for infrastructure
- Blue/green deployments
- Automated testing

### Environments
- `dev` - Development testing
- `staging` - Pre-production
- `prod` - Production

## Cost Estimation

### Free Tier Limits
- Lambda: 1M requests/month
- DynamoDB: 25GB, 25 RCU/WCU
- S3: 5GB, 20K GET, 2K PUT
- API Gateway: 1M requests/month

### Expected Usage (MVP)
- 1,000 users
- 100 items/day
- 500 API calls/day
- Well within Free Tier

### Monitoring
- AWS Cost Explorer
- Budget alerts
- Daily cost reports
