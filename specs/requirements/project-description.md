# EcoBid - Project Description

## Problem Statement

People want to declutter their homes but face friction:
- **Platform dependency**: Facebook Marketplace groups lock users into one platform
- **Too much effort**: Vinted, eBay, Craigslist require professional photos, detailed descriptions, pricing research
- **No local "free stuff" hub**: No dedicated app for giving away items in your neighborhood
- **Decision paralysis**: "Should I sell this for $5 or just throw it away?"

## Target Users

### Primary Users
- **Declutterers**: People cleaning out closets, moving, downsizing
- **Bargain hunters**: People looking for free/cheap items nearby
- **Eco-conscious givers**: Want items reused, not trashed

### Secondary Users
- **Students**: Furnishing apartments on zero budget
- **Parents**: Outgrown kids items (clothes, toys, gear)
- **Minimalists**: Regular decluttering lifestyle

## Solution Overview

**EcoBid** is a mobile-first marketplace with two modes:

### Mode 1: Free Stuff (Primary Feature)
- **Location-based**: See free items within X km radius
- **Categories**: Furniture, clothes, electronics, books, etc.
- **Reservation system**: 
  - Buyer reserves item
  - Seller confirms pickup time
  - Status: Available → Reserved → Confirmed → Completed
- **Zero friction**: Quick photo, category, done

### Mode 2: Quick Auctions (Secondary Feature)
- **Minimal effort**: One photo, category, minimum price (e.g., $5)
- **Let market decide**: 24-48 hour micro-auctions
- **For items worth $5-50**: Too valuable to give away, too cheap for Vinted effort
- **Auto-pricing**: Suggest minimum based on category

## Key Features

### MVP (Phase 1)
- User authentication (AWS Cognito)
- Post free items with photo (S3)
- Location-based search (DynamoDB + geohashing)
- Reservation workflow (EventBridge + Lambda)
- Push notifications (SNS)
- Mobile app (React Native)

### Enhanced (Phase 2)
- Quick auction mode
- AI category detection (Rekognition)
- Chat between users (AppSync)
- Rating system
- Item history tracking

### Advanced (Phase 3)
- Community features (local groups)
- Scheduled pickups (calendar integration)
- Donation receipts for tax purposes
- Analytics dashboard

## Unique Value Proposition

**"Give it away, or let the market decide"**

Unlike existing platforms:
- **Not platform-locked**: Independent app, not Facebook-dependent
- **Effort-optimized**: Designed for "good enough" listings, not professional sellers
- **Free-first**: Primary focus on giving away, not selling
- **Hyper-local**: Neighborhood-focused, not nationwide shipping
- **Event-driven**: Real-time notifications, status updates

## Technical Innovation

### Serverless Event-Driven Architecture
- **Lambda**: Stateless business logic
- **EventBridge**: Workflow orchestration (reservation → pickup → completion)
- **DynamoDB Streams**: Real-time updates
- **AppSync**: Real-time GraphQL subscriptions
- **Step Functions**: Multi-step auction workflows

### AWS AI Integration
- **Rekognition**: Auto-categorize items from photos
- **Comprehend**: Detect inappropriate content
- **Location Service**: Geospatial queries
- **Bedrock**: Generate item descriptions from photos

### Free Tier Optimized
- Geohashing for efficient location queries
- Image compression before S3 upload
- DynamoDB single-table design
- Lambda cold start optimization

## Market Differentiation

| Feature | EcoBid | Facebook Marketplace | Vinted/eBay |
|---------|--------|---------------------|-------------|
| Platform independent | ✅ | ❌ Facebook-only | ✅ |
| Free items focus | ✅ Primary | ⚠️ Mixed | ❌ Selling only |
| Minimal effort | ✅ | ⚠️ | ❌ High effort |
| Hyper-local | ✅ | ⚠️ | ❌ Shipping focus |
| Reservation system | ✅ | ❌ | ❌ |
| Quick auctions | ✅ | ❌ | ❌ |

## User Flows

### Free Item Flow
1. Seller: Take photo → Select category → Post (30 seconds)
2. Buyer: Browse nearby → Reserve item
3. Seller: Confirm pickup time
4. Buyer: Pick up item
5. Both: Mark as completed

### Quick Auction Flow
1. Seller: Photo → Category → Minimum price → Post
2. System: 24-hour auction starts
3. Buyers: Place bids
4. System: Auction ends, winner notified
5. Winner: Arrange pickup
6. Complete transaction

## Success Criteria

**Technical**:
- Sub-second location search
- 99.9% uptime
- Support 10,000+ concurrent users
- Stay within AWS Free Tier

**Business**:
- 1,000+ beta users
- 5,000+ items posted
- 70%+ completion rate (reserved → picked up)
- 4+ star rating

**Competition**:
- Comprehensive Kiro documentation
- Event-driven architecture showcase
- Strong community engagement
- Clear social impact (waste reduction)
