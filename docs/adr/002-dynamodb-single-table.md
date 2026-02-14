# ADR-002: DynamoDB Single-Table Design

**Date**: 2026-02-13  
**Status**: Accepted

## Context

EcoBid needs a database solution that:
- Stays within AWS Free Tier (25 RCU/WCU, 25GB storage)
- Supports multiple access patterns (by user, location, category, time)
- Scales automatically with user growth
- Provides low-latency queries (< 100ms)
- Integrates with event-driven architecture (streams)

### Access Patterns Required

1. Get user profile by userId
2. Get all items by userId
3. Get items by location (geohash) + category
4. Get item details by itemId
5. Get reservations for an item
6. Get user's active reservations
7. Get auction details and bids
8. Get items by status (available, reserved)

### Options Considered

**Option 1: Multiple DynamoDB Tables**
- Separate tables for users, items, reservations, auctions
- Pros: Simple, clear separation
- Cons: Higher RCU/WCU usage, no transactions across tables, more complex queries

**Option 2: Relational Database (RDS)**
- PostgreSQL or MySQL on RDS Free Tier
- Pros: Familiar SQL, complex queries, transactions
- Cons: Fixed capacity (20GB), manual scaling, higher latency, no streams

**Option 3: DynamoDB Single-Table Design**
- One table with composite keys and GSIs
- Pros: Minimal RCU/WCU, fast queries, streams, auto-scaling
- Cons: Complex design, requires careful planning

## Decision

We will use **DynamoDB Single-Table Design** with the following structure:

### Primary Key Design

```
PK (Partition Key)        SK (Sort Key)              Entity Type
--------------------------------------------------------------------------------
USER#<userId>             PROFILE                    User profile
USER#<userId>             ITEM#<itemId>              User's item (for queries)
ITEM#<itemId>             METADATA                   Item details
ITEM#<itemId>             RESERVATION#<resId>        Item reservation
ITEM#<itemId>             AUCTION#<auctionId>        Auction details
AUCTION#<auctionId>       BID#<bidId>#<timestamp>    Auction bid
GEO#<geohash>             ITEM#<itemId>#<timestamp>  Location index
CATEGORY#<cat>            ITEM#<itemId>#<timestamp>  Category index
```

### Global Secondary Indexes

**GSI1: Location-based queries**
- PK: `geohash` (precision 6 for ~1km radius)
- SK: `timestamp` (for sorting by newest)
- Projection: ALL
- Use case: "Show me free items within 5km"

**GSI2: Category queries**
- PK: `category`
- SK: `timestamp`
- Projection: ALL
- Use case: "Show me all furniture items"

### Example Queries

**Get user profile**:
```
GetItem(PK="USER#user_123", SK="PROFILE")
```

**Get user's items**:
```
Query(PK="USER#user_123", SK begins_with "ITEM#")
```

**Get items near location**:
```
Query(GSI1, PK="u3qcnm", SK > "2026-02-01")
```

**Get items by category**:
```
Query(GSI2, PK="furniture", SK > "2026-02-01")
```

**Get item with reservations**:
```
Query(PK="ITEM#item_456", SK begins_with "RESERVATION#")
```

## Consequences

### Positive

✅ **Free Tier Optimized**: Single table uses minimal RCU/WCU  
✅ **Fast Queries**: All access patterns supported with single-digit ms latency  
✅ **Scalable**: Auto-scaling with on-demand billing  
✅ **Event-Driven**: DynamoDB Streams for real-time processing  
✅ **Flexible**: Easy to add new access patterns with GSIs  
✅ **Cost-Effective**: Pay only for what you use

### Negative

⚠️ **Complex Design**: Requires careful planning of keys and indexes  
⚠️ **Learning Curve**: Team needs to understand single-table patterns  
⚠️ **Limited Queries**: Can't do arbitrary SQL-like queries  
⚠️ **Data Duplication**: Some data duplicated across items (acceptable trade-off)

### Mitigation Strategies

1. **Documentation**: Comprehensive access pattern documentation
2. **Helper Functions**: Utility functions for common queries
3. **Testing**: Extensive testing of all access patterns
4. **Monitoring**: CloudWatch metrics for throttling, latency

## Implementation Notes

### Geohashing Strategy

Use precision-6 geohashes (~1.2km x 0.6km cells):
- Warsaw center: `u3qcnm`
- Query multiple geohashes for larger radius
- Example: 5km radius = 9 geohashes to query

### Timestamp Format

ISO 8601 with milliseconds for sorting:
```
2026-02-13T10:30:45.123Z
```

### TTL Configuration

Enable TTL on `expiresAt` attribute:
- Expired reservations (24 hours)
- Completed items (90 days)
- Old notifications (30 days)

### Capacity Planning

**Free Tier Limits**:
- 25 RCU/WCU provisioned
- 25GB storage
- Streams included

**Expected Usage (1K users)**:
- Storage: < 1GB
- Reads: < 10 RCU
- Writes: < 5 WCU

**Scaling Strategy**:
- Start with on-demand billing
- Monitor usage for 30 days
- Switch to provisioned if predictable

## References

- [AWS DynamoDB Best Practices](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/best-practices.html)
- [Single-Table Design](https://www.alexdebrie.com/posts/dynamodb-single-table/)
- [Geohashing for Location Queries](https://en.wikipedia.org/wiki/Geohash)

## Related ADRs

- [ADR-001: Node.js Runtime](./001-nodejs-runtime.md)
- ADR-003: Serverless Event-Driven Architecture (planned)
