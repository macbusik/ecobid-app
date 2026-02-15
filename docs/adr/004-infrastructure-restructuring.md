# ADR-004: Infrastructure Restructuring

**Date**: 2026-02-15  
**Status**: Accepted

## Context

After completing initial documentation and specs, we recognized the need to adopt spec-driven development principles more rigorously. The initial infrastructure (deployed Feb 13, 2026) was a proof-of-concept that preceded finalized specifications.

**Initial Infrastructure** (Destroyed Feb 15, 2026):
- DynamoDB: ecobid-prod-items
- S3: ecobid-prod-images  
- Cognito: ecobid-prod-users
- Lambda: ecobid-prod-api-handler (placeholder)
- API Gateway: ecobid-prod-api
- EventBridge: ecobid-prod-events

**Reason for Destruction**:
- Specs were refined after initial deployment
- Need to align infrastructure with finalized specifications
- Opportunity to improve architecture based on lessons learned
- Demonstrate iterative, spec-driven development for competition

## Decision

Destroy all production infrastructure and rebuild according to refined specifications following spec-driven development principles:

1. **Specs First**: All specifications finalized before infrastructure
2. **API Contract**: OpenAPI spec drives API Gateway configuration
3. **Data Model**: DynamoDB design follows refined access patterns
4. **Event Schema**: EventBridge events match documented schemas
5. **Infrastructure as Code**: Terraform modules match spec requirements

## Destruction Process

**Method**: Manual AWS CLI (Terraform remote state inaccessible)

**Resources Destroyed** (Feb 15, 2026 14:30 CET):
1. ✅ API Gateway: ecobid-prod-api (bunltgh9ql)
2. ✅ EventBridge: ecobid-prod-events
3. ✅ DynamoDB: ecobid-prod-items (0 items, safe to delete)
4. ✅ S3: ecobid-prod-images (0 objects, safe to delete)
5. ✅ Cognito: ecobid-prod-users (0 users, safe to delete)

**Data Loss**: None (test deployment only, no production data)

## Consequences

### Positive

✅ **Clean Slate**: Build infrastructure that perfectly matches specs  
✅ **Spec-Driven**: Demonstrates proper spec-driven development workflow  
✅ **Improved Architecture**: Apply lessons learned from initial deployment  
✅ **Competition Story**: Shows iterative development and refinement  
✅ **No Data Loss**: Test deployment only, safe to destroy  
✅ **Cost Savings**: No ongoing costs during restructuring

### Negative

⚠️ **Time Investment**: Need to redeploy infrastructure  
⚠️ **Submission Timeline**: 6 days remaining (manageable)  
⚠️ **Documentation Updates**: Need to update architecture docs

### Mitigation Strategies

1. **Rapid Redeployment**: Terraform code exists, can redeploy quickly
2. **Parallel Work**: Can work on mobile app while infrastructure rebuilds
3. **Lessons Applied**: Second deployment will be faster and better
4. **Documentation**: Update docs to reflect new architecture

## Rebuild Plan

### Phase 1: Spec Validation (Complete)
- ✅ All specs finalized and documented
- ✅ OpenAPI specification complete
- ✅ Data models defined
- ✅ Event schemas documented

### Phase 2: Infrastructure Refinement (Next)
- [ ] Review Terraform modules against specs
- [ ] Update DynamoDB schema if needed
- [ ] Refine Lambda function structure
- [ ] Validate API Gateway configuration
- [ ] Test EventBridge event flows

### Phase 3: Deployment (After Refinement)
- [ ] Deploy to production
- [ ] Validate against specs
- [ ] Update documentation
- [ ] Begin API implementation

## Timeline Impact

**Original Plan**: API implementation starting Feb 15  
**Revised Plan**: Infrastructure refinement + deployment (1 day), then API implementation

**Submission Deadline**: Jan 21, 2026 (6 days remaining)  
**Impact**: Minimal - infrastructure deployment is fast, specs are complete

## Lessons Learned

1. **Specs First**: Always finalize specs before infrastructure
2. **Iterative Development**: Willing to rebuild for better architecture
3. **Test Deployments**: Safe to destroy and rebuild test infrastructure
4. **Documentation**: Keep specs and infrastructure in sync
5. **Competition Value**: Demonstrates thoughtful, iterative development

## References

- Destruction Workflow: docs/infrastructure-destroy-workflow.md
- Current Specs: specs/requirements/
- API Specification: specs/api/openapi.yaml
- Architecture Decisions: docs/adr/002-dynamodb-single-table.md, docs/adr/003-serverless-event-driven.md

## Related ADRs

- [ADR-001: Node.js Runtime](./001-nodejs-runtime.md)
- [ADR-002: DynamoDB Single-Table Design](./002-dynamodb-single-table.md)
- [ADR-003: Serverless Event-Driven Architecture](./003-serverless-event-driven.md)
