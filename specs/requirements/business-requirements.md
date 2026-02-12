# Business Requirements - EcoBid

## Vision

Create a platform-independent, mobile-first marketplace that makes decluttering effortless by focusing on giving away items for free, with an optional quick-auction mode for items worth minimal effort.

## Core Principles

1. **Free-first**: Primary focus on giving items away, not selling
2. **Minimal friction**: 30-second listing process
3. **Hyper-local**: Neighborhood-focused (no shipping)
4. **Platform independent**: Not tied to Facebook or any social network
5. **Event-driven**: Real-time status updates and notifications

## Business Requirements

### BR-1: Dual-Mode Marketplace

**Free Mode (Primary)**
- Users can post items for free
- Location-based discovery (radius search)
- Reservation system with status workflow
- No payment processing required

**Quick Auction Mode (Secondary)**
- Minimal-effort auctions for items worth $5-50
- 24-48 hour duration
- Automatic winner selection
- Simple payment integration

### BR-2: User Types

**Givers/Sellers**
- Post items with minimal effort (photo + category)
- Manage reservations/bids
- Confirm pickups
- Rate buyers

**Takers/Buyers**
- Browse nearby items
- Reserve free items or bid on auctions
- Arrange pickup
- Rate sellers

### BR-3: Item Lifecycle

#### Free Item Workflow
```
Available → Reserved → Confirmed → Picked Up → Completed
         ↓
      Cancelled (if no-show)
```

**States**:
- **Available**: Listed, visible to all
- **Reserved**: Buyer reserved, waiting for seller confirmation
- **Confirmed**: Seller confirmed pickup time
- **Picked Up**: Buyer collected item
- **Completed**: Both parties confirmed transaction
- **Cancelled**: Reservation cancelled, back to Available

#### Auction Item Workflow
```
Active → Ended → Winner Selected → Picked Up → Completed
      ↓
   Expired (no bids)
```

### BR-4: Location-Based Discovery

**Requirements**:
- Search radius: 1km, 5km, 10km, 25km
- Sort by: Distance, newest, category
- Filter by: Category, condition, availability
- Map view of items

**Technical**:
- Geohashing for efficient queries
- DynamoDB GSI for location + category
- Real-time updates when new items posted nearby

### BR-5: Categories

**Initial Categories**:
- Furniture
- Electronics
- Clothing & Accessories
- Books & Media
- Home & Garden
- Kids & Baby
- Sports & Outdoors
- Other

**Future**: AI-powered auto-categorization (Rekognition)

### BR-6: Reservation System

**Free Items**:
1. Buyer clicks "Reserve"
2. Seller receives notification
3. Seller confirms pickup time (or declines)
4. Buyer receives confirmation
5. Both mark as "Picked Up" when complete
6. Auto-cancel if no response in 24 hours

**Auction Items**:
1. Auction ends automatically
2. Winner notified
3. Seller confirms winner
4. Arrange pickup (similar to free items)

### BR-7: Notifications

**Push Notifications**:
- New item posted nearby (optional, by category)
- Reservation request received
- Reservation confirmed/declined
- Pickup reminder
- Auction ending soon
- You won an auction

**In-App Notifications**:
- All push notifications
- Messages from other users
- System announcements

### BR-8: User Profiles

**Public Info**:
- Username
- Rating (1-5 stars)
- Number of items given/sold
- Number of items received
- Member since date
- Location (city level only)

**Private Info**:
- Email
- Phone (optional, for pickup coordination)
- Exact location (only shared when pickup confirmed)

### BR-9: Trust & Safety

**Required**:
- Report item (inappropriate, scam, etc.)
- Block user
- Rating system (both parties rate after completion)
- Photo required for all listings
- Content moderation (AWS Comprehend)

**Future**:
- Verified users (phone verification)
- Community moderators
- Dispute resolution

### BR-10: Quick Auction Specifics

**Auction Settings**:
- Duration: 24 or 48 hours
- Minimum bid: $5-50 (seller sets)
- Bid increment: $1
- Reserve price: Optional
- Auto-extend: +10 minutes if bid in last 5 minutes

**Payment**:
- Cash on pickup (MVP)
- Future: In-app payment (Stripe)

## Non-Functional Requirements

### NFR-1: Performance
- Location search: < 500ms
- Image upload: < 3 seconds
- Push notification: < 5 seconds
- App launch: < 2 seconds

### NFR-2: Scalability
- Support 10,000 concurrent users
- 100,000 items in database
- 1,000 new items per day
- Stay within AWS Free Tier initially

### NFR-3: Availability
- 99.9% uptime
- Graceful degradation (offline mode for browsing)
- Data backup and recovery

### NFR-4: Security
- Authentication required for all actions
- HTTPS only
- No PII in logs
- Image content moderation
- Rate limiting on API

### NFR-5: Usability
- 30-second listing process
- 3-tap reservation
- Intuitive navigation
- Accessible (WCAG 2.1 AA)

## Success Metrics

### User Engagement
- Daily active users (DAU)
- Items posted per day
- Reservation rate (% of items reserved)
- Completion rate (% of reservations completed)
- Return user rate

### Business Metrics
- User growth rate
- Items given away (social impact)
- Auction conversion rate
- Average time to pickup
- User satisfaction (NPS)

### Technical Metrics
- API response time
- Error rate
- AWS costs
- Free Tier utilization
- App crash rate

## Future Enhancements

### Phase 2
- In-app messaging
- Scheduled pickups (calendar integration)
- Community groups (neighborhood-specific)
- Wishlist/saved searches
- Item history tracking

### Phase 3
- Donation receipts (tax purposes)
- Charity partnerships
- Bulk listings (moving sales)
- Delivery service integration
- Social features (share to social media)

## Out of Scope (MVP)

- Shipping/delivery
- In-app payment (auctions are cash-only MVP)
- Social network integration
- Multi-language support
- Web application (mobile-only MVP)
- Business accounts
- Promoted listings
