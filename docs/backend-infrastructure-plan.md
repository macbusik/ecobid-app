# Backend Infrastructure Implementation Plan

## Objective
Implement complete serverless backend infrastructure for EcoBid application following TR-2 (AWS Free Tier compliance) and event-driven architecture.

## Architecture Components

### 1. DynamoDB - Data Layer
**Single-table design** for cost optimization:
- **Main Table**: `ecobid-prod-items`
  - PK/SK pattern for multiple entity types
  - GSI1: Location-based queries (geohash + category)
  - GSI2: User-based queries (userId + timestamp)
  - TTL enabled for expired items
  - Streams enabled for event processing

**Entities**:
- Items (free + auction)
- Users
- Reservations
- Bids
- Transactions

### 2. S3 - Storage Layer
**Buckets**:
- `ecobid-prod-images`: Item photos
  - Lifecycle: Delete after 90 days
  - CORS enabled for mobile uploads
  - Encryption: AES256
  - Versioning: Enabled

### 3. Cognito - Authentication
**User Pool**: `ecobid-prod-users`
- Email-based authentication
- Password policy: 8+ chars, uppercase, lowercase, numbers
- MFA: Optional
- Custom attributes: location, rating

**User Pool Client**: Mobile app
- Auth flows: USER_SRP_AUTH, REFRESH_TOKEN_AUTH

### 4. Lambda Functions
**API Handlers** (synchronous):
- `CreateItem`: POST /items
- `GetItems`: GET /items (with filters)
- `GetItem`: GET /items/{id}
- `UpdateItem`: PUT /items/{id}
- `DeleteItem`: DELETE /items/{id}
- `ReserveItem`: POST /items/{id}/reserve
- `ConfirmReservation`: POST /reservations/{id}/confirm
- `CreateBid`: POST /items/{id}/bids
- `GetUserProfile`: GET /users/{id}
- `UpdateUserProfile`: PUT /users/{id}

**Event Processors** (asynchronous):
- `ProcessNewItem`: DynamoDB Stream → Index, notify nearby users
- `ProcessReservation`: EventBridge → Notify seller, schedule expiry
- `ProcessImageUpload`: S3 Event → Resize, moderate
- `EndAuction`: EventBridge Scheduled → Select winner, notify
- `CancelExpiredReservations`: EventBridge Scheduled → Cleanup

### 5. API Gateway
**REST API**: `ecobid-prod-api`
- Cognito authorizer
- CORS enabled
- Request validation
- Rate limiting: 1000 req/sec per user
- Stages: prod

**Endpoints**:
```
POST   /items                    # Create item
GET    /items                    # List items (with filters)
GET    /items/{id}               # Get item details
PUT    /items/{id}               # Update item
DELETE /items/{id}               # Delete item
POST   /items/{id}/reserve       # Reserve item
POST   /items/{id}/bids          # Place bid
GET    /users/{id}               # Get user profile
PUT    /users/{id}               # Update user profile
POST   /reservations/{id}/confirm # Confirm reservation
```

### 6. EventBridge
**Event Bus**: `ecobid-prod-events`

**Rules**:
- `ItemCreated` → Lambda (ProcessNewItem)
- `ReservationCreated` → Lambda (ProcessReservation)
- `AuctionEnded` → Lambda (EndAuction)
- `Schedule: rate(1 hour)` → Lambda (CancelExpiredReservations)

## Free Tier Compliance (TR-2)

### DynamoDB
- ✅ PAY_PER_REQUEST billing (no provisioned capacity)
- ✅ 25GB storage limit (estimated: <1GB for MVP)
- ✅ 25 RCU/WCU included

### Lambda
- ✅ 1M requests/month (estimated: 100K for MVP)
- ✅ 400,000 GB-seconds compute
- ✅ 128MB memory per function (minimal)

### API Gateway
- ✅ 1M API calls/month (estimated: 100K for MVP)

### S3
- ✅ 5GB storage (estimated: 2GB for MVP)
- ✅ 20,000 GET, 2,000 PUT requests/month

### Cognito
- ✅ 50,000 MAUs (estimated: 100 users for MVP)

### EventBridge
- ✅ Free for AWS service events
- ✅ $1/million custom events (minimal usage)

## Implementation Order

### Phase 1: Core Data & Auth (This PR)
1. ✅ DynamoDB table with GSIs
2. ✅ S3 images bucket
3. ✅ Cognito user pool

### Phase 2: API Layer
4. Lambda functions (API handlers)
5. API Gateway with Cognito auth
6. IAM roles and policies

### Phase 3: Event Processing
7. EventBridge event bus and rules
8. Lambda event processors
9. DynamoDB Streams integration

## Terraform Modules Structure

```
modules/
├── dynamodb/          # Single-table design
├── s3/                # Images bucket (reusable)
├── cognito/           # User pool + client
├── lambda/            # Function definitions
├── api_gateway/       # REST API + authorizer
└── eventbridge/       # Event bus + rules
```

## Next Steps

1. Update DynamoDB module with complete schema
2. Update Cognito module with custom attributes
3. Implement Lambda module with function definitions
4. Implement API Gateway module with routes
5. Implement EventBridge module with rules
6. Add IAM policies for least privilege access

## Success Criteria

- ✅ All infrastructure deployed via Terraform
- ✅ Free Tier compliant
- ✅ Event-driven architecture implemented
- ✅ API endpoints functional
- ✅ Authentication working
- ✅ Ready for backend code implementation
