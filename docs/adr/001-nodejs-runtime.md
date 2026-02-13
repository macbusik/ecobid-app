# Architecture Decision Record: Node.js for Lambda Functions

## Status
Accepted

## Context
We need to choose a runtime for AWS Lambda functions in the EcoBid backend. The main candidates are:
- Node.js (JavaScript/TypeScript)
- Python
- Go

## Decision
We will use **Node.js 20.x** for all Lambda functions.

## Rationale

### 1. Cold Start Performance
**Node.js**: ~200-300ms cold start
- Acceptable for REST API use case
- Improved significantly in Node.js 20.x
- Free Tier: 400,000 GB-seconds includes cold starts

**Python**: ~300-500ms cold start
**Go**: ~100-150ms (fastest, but see trade-offs below)

**Verdict**: Node.js cold starts are acceptable for our use case (mobile app, not real-time trading).

### 2. Development Velocity
**Node.js**:
- ✅ Single language for frontend (React Native) and backend
- ✅ Shared code possible (validation, types, utilities)
- ✅ JSON-native (DynamoDB, API Gateway, EventBridge all use JSON)
- ✅ Extensive AWS SDK support
- ✅ Large ecosystem (npm packages)

**Python**:
- Different language from frontend
- Requires context switching
- Good AWS SDK, but less JSON-native

**Go**:
- Compiled language (slower iteration)
- Different language from frontend
- Smaller ecosystem for serverless

**Verdict**: Node.js maximizes development velocity for a small team/solo developer.

### 3. AWS Free Tier Optimization
**Node.js**:
- ✅ 128MB memory sufficient for most handlers
- ✅ Fast execution (event loop model)
- ✅ Efficient for I/O-bound operations (DynamoDB, S3, API calls)

**Memory usage comparison** (typical API handler):
- Node.js: 128MB (our choice)
- Python: 128-256MB
- Go: 128MB

**Execution time** (DynamoDB query + response):
- Node.js: 50-100ms
- Python: 80-150ms
- Go: 30-80ms

**Free Tier calculation** (1M requests/month):
- Node.js (128MB, 75ms avg): 9,600 GB-seconds ✅
- Python (256MB, 115ms avg): 29,440 GB-seconds ✅
- Go (128MB, 55ms avg): 7,040 GB-seconds ✅

**Verdict**: All fit within Free Tier (400,000 GB-seconds), Node.js is optimal balance.

### 4. Kiro AI Assistant Optimization
**Node.js**:
- ✅ Kiro has extensive training on JavaScript/Node.js patterns
- ✅ Better code generation quality for Node.js
- ✅ More accurate suggestions and debugging
- ✅ Larger corpus of serverless Node.js examples

**Python**:
- Good Kiro support, but less serverless-specific

**Go**:
- Limited Kiro training on Go serverless patterns

**Verdict**: Node.js maximizes Kiro effectiveness (TR-1 requirement).

### 5. Ecosystem & Libraries
**Node.js**:
- ✅ `aws-sdk` (v3) - modular, tree-shakeable
- ✅ `uuid` - ID generation
- ✅ `joi` / `zod` - validation (shared with frontend)
- ✅ `dayjs` - date handling
- ✅ `bcrypt` - password hashing
- ✅ Extensive DynamoDB libraries

**Python**:
- `boto3` - comprehensive but monolithic
- Good data science libraries (not needed for our use case)

**Go**:
- Smaller ecosystem
- More manual implementation required

**Verdict**: Node.js has the richest serverless ecosystem.

### 6. JSON Handling
**Node.js**:
- ✅ Native JSON support
- ✅ No serialization overhead
- ✅ Direct mapping to DynamoDB documents
- ✅ API Gateway integration seamless

**Python**:
- Requires dict ↔ JSON conversion
- Type hints help but add verbosity

**Go**:
- Requires struct definitions
- Marshal/unmarshal overhead

**Verdict**: Node.js is most natural for JSON-heavy workloads.

### 7. TypeScript Option
**Node.js**:
- ✅ Can upgrade to TypeScript later
- ✅ Type safety without compilation overhead
- ✅ Shared types with React Native frontend

**Python**:
- Type hints available but optional

**Go**:
- Compiled, type-safe (but slower iteration)

**Verdict**: Node.js offers best of both worlds (start with JS, add TS later).

### 8. Competition Requirements (TR-1)
**Kiro Usage Documentation**:
- Node.js allows us to demonstrate Kiro's effectiveness
- Better code generation = more impressive submission
- Easier to document Kiro's contributions

**Verdict**: Node.js maximizes TR-1 compliance demonstration.

## Consequences

### Positive
- ✅ Fast development velocity
- ✅ Single language across stack
- ✅ Excellent Kiro support
- ✅ Free Tier optimized
- ✅ Rich ecosystem
- ✅ JSON-native

### Negative
- ❌ Slightly slower cold starts than Go (acceptable trade-off)
- ❌ Not ideal for CPU-intensive tasks (not our use case)
- ❌ Requires careful memory management (128MB limit)

### Mitigation
- Use async/await for I/O operations (maximize efficiency)
- Keep dependencies minimal (reduce cold start time)
- Monitor CloudWatch metrics (optimize if needed)
- Consider Go for specific high-performance functions if needed later

## Alternatives Considered

### Python
**Pros**: Popular for AWS Lambda, good AWS SDK, data science libraries
**Cons**: Different from frontend, slower than Node.js for I/O, less Kiro optimization
**Rejected**: Development velocity and Kiro support outweigh benefits

### Go
**Pros**: Fastest cold starts, compiled, type-safe
**Cons**: Slower iteration, different from frontend, smaller ecosystem, less Kiro support
**Rejected**: Development velocity more important than marginal performance gains

## References
- [AWS Lambda Runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html)
- [AWS Lambda Cold Start Analysis](https://mikhail.io/serverless/coldstarts/aws/)
- [Node.js Best Practices for Lambda](https://docs.aws.amazon.com/lambda/latest/dg/nodejs-handler.html)

## Decision Date
2026-02-13

## Decision Makers
- Development Team (with Kiro AI assistance)

## Status
✅ Implemented - Node.js 20.x runtime configured in Lambda module
