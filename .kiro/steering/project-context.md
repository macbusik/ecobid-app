---
inclusion: auto
---

# EcoBid Project Context

## Project Overview

EcoBid is a mobile-first marketplace for the AWS 10,000 AIdeas Challenge. The platform enables users to give away items for free or run quick auctions, focusing on reducing waste and simplifying decluttering.

**Competition Deadline**: Initial submission by January 21, 2026 11:59pm PT

## Core Principles

1. **Free-First**: Primary focus on giving items away, not selling
2. **Minimal Friction**: 30-second listing process
3. **Hyper-Local**: Neighborhood-focused (no shipping)
4. **Platform Independent**: Not tied to Facebook or any social network
5. **Event-Driven**: Real-time status updates and notifications

## Deployed Infrastructure (Production)

- DynamoDB: ecobid-prod-items (single-table design)
- S3: ecobid-prod-images (encrypted, versioned)
- Cognito: ecobid-prod-users (JWT authentication)
- Lambda: ecobid-prod-api-handler (Node.js 20.x)
- API Gateway: ecobid-prod-api (REST API)
- EventBridge: ecobid-prod-events (event bus)

## AWS Free Tier Compliance (CRITICAL)

All development must stay within AWS Free Tier limits:
- Lambda: 1M requests/month, 400K GB-seconds
- DynamoDB: 25GB storage, 25 RCU/WCU
- S3: 5GB storage, 20K GET, 2K PUT
- API Gateway: 1M requests/month
- Cognito: 50K MAUs

## Code Standards

- Node.js 20.x runtime for Lambda
- Single responsibility per function
- Environment variables for configuration
- Comprehensive error handling
- Input validation on all endpoints
- API response < 500ms, Lambda cold start < 1s
- 80% test coverage target

## Git Workflow

- Main branch: Production-ready code
- Commit format: type(scope): description
- Types: feat, fix, docs, spec, infra, test, chore

## Competition Requirements

- Document all Kiro interactions in docs/kiro-usage.md
- Log sessions in .sessions/YYYY-MM-DD.md
- Current status: 65% complete (docs done, need API + mobile app)

## Current Priority

API Implementation (Lambda handlers):
- CreateItem, GetItems, ReserveItem
- DynamoDB data access layer
- S3 presigned URL generation
- API Gateway integration
- Unit tests

## Key References

- API Spec: specs/api/openapi.yaml
- Architecture: docs/aws-architecture.md
- Database Design: docs/adr/002-dynamodb-single-table.md
- Event-Driven: docs/adr/003-serverless-event-driven.md
- Business Requirements: specs/requirements/business-requirements.md
- Market Impact: specs/requirements/market-impact.md
- Submission Checklist: docs/submission-checklist.md
