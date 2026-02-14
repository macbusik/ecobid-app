---
inclusion: fileMatch
fileMatchPattern: 'backend/**/*.js'
---

# API Development Guidelines

## OpenAPI Specification

All API endpoints MUST follow the OpenAPI 3.0 specification defined in:
**specs/api/openapi.yaml**

Before implementing any endpoint, review the spec for:
- Request/response schemas
- Authentication requirements
- Error responses
- Validation rules

## Lambda Handler Structure

```javascript
// handlers/<domain>/<action>.js
const { businessLogic } = require('../../services/<domain>');

exports.handler = async (event) => {
  try {
    // 1. Parse and validate input
    const body = JSON.parse(event.body);
    
    // 2. Extract user from Cognito authorizer
    const userId = event.requestContext.authorizer.claims.sub;
    
    // 3. Call business logic
    const result = await businessLogic(userId, body);
    
    // 4. Return success response
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify(result)
    };
  } catch (error) {
    console.error('Error:', error);
    
    // 5. Return error response
    return {
      statusCode: error.statusCode || 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        error: {
          code: error.code || 'INTERNAL_ERROR',
          message: error.message
        }
      })
    };
  }
};
```

## DynamoDB Access Patterns

Reference: **docs/adr/002-dynamodb-single-table.md**

Single-table design with composite keys:
- PK: `USER#${userId}`, `ITEM#${itemId}`, `GEO#${geohash}`
- SK: `PROFILE`, `METADATA`, `RESERVATION#${id}`

## Environment Variables

Always use environment variables for configuration:
- `TABLE_NAME` - DynamoDB table name
- `BUCKET_NAME` - S3 bucket for images
- `USER_POOL_ID` - Cognito user pool ID
- `EVENT_BUS_NAME` - EventBridge event bus

## Error Handling

All errors must follow the API spec format:
```javascript
class ApiError extends Error {
  constructor(code, message, statusCode = 400) {
    super(message);
    this.code = code;
    this.statusCode = statusCode;
  }
}
```

## Performance Targets

- API response time: < 500ms (p95)
- Lambda cold start: < 1s
- DynamoDB query: < 100ms

## Security Checklist

- [ ] Validate all user inputs
- [ ] Use parameterized queries
- [ ] Never log sensitive data
- [ ] Verify user authorization
- [ ] Use HTTPS only
- [ ] Enable CORS properly
