# Development Guidelines

## Infrastructure Development

### Technology
- **Primary**: Terraform (infrastructure as code)
- **Fallback**: CloudFormation (AWS native)
- **Location**: `infrastructure/terraform/`

### Standards
- All resources must stay within AWS Free Tier limits
- Tag all resources: `Project=EcoBid`, `Environment=dev|prod`
- Use variables for configuration
- Document all services in `docs/aws-architecture.md`

### Workflow
1. Write Terraform configuration
2. Run `terraform plan` to validate
3. Document in architecture doc
4. Apply with `terraform apply`
5. Commit both code and state references

### Free Tier Monitoring
```bash
# Set up billing alerts
aws cloudwatch put-metric-alarm \
  --alarm-name ecobid-free-tier-alert \
  --alarm-description "Alert when approaching Free Tier limits"
```

---

## Backend Development

### Technology
- **Runtime**: Node.js 20.x (Lambda)
- **Framework**: Minimal dependencies
- **Database**: DynamoDB
- **Location**: `backend/src/`

### Structure
```
backend/
├── src/
│   ├── handlers/        # Lambda entry points
│   ├── services/        # Business logic
│   ├── models/          # Data models
│   ├── utils/           # Shared utilities
│   └── middleware/      # Auth, validation
└── tests/               # Unit & integration tests
```

### Standards
- One handler per Lambda function
- Keep handlers thin (< 50 lines)
- Business logic in services
- Environment variables for config
- Error handling on all async operations
- Input validation on all endpoints

### Lambda Handler Template
```javascript
// handlers/bidding/create.js
const { createBid } = require('../../services/bidding');

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const result = await createBid(body);
    
    return {
      statusCode: 200,
      body: JSON.stringify(result)
    };
  } catch (error) {
    console.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    };
  }
};
```

### API Design
- Follow OpenAPI spec in `specs/api/`
- RESTful conventions
- Consistent error responses
- API versioning: `/v1/resource`

---

## Frontend Development

### Technology
- **Framework**: React Native (cross-platform)
- **State**: React Context + Hooks
- **API Client**: Axios
- **Location**: `frontend/mobile/`

### Structure
```
frontend/mobile/
├── src/
│   ├── screens/         # Full-page views
│   ├── components/      # Reusable UI components
│   ├── services/        # API clients
│   ├── hooks/           # Custom React hooks
│   ├── context/         # Global state
│   ├── utils/           # Helpers
│   └── assets/          # Images, fonts
└── tests/
```

### Standards
- Functional components only
- Custom hooks for logic reuse
- Prop validation with PropTypes
- Responsive design (mobile-first)
- Accessibility labels on all interactive elements
- Dark mode support

### Component Template
```javascript
// components/BidCard.js
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import PropTypes from 'prop-types';

const BidCard = ({ product, currentBid, onBid }) => {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>{product.name}</Text>
      <Text style={styles.bid}>${currentBid}</Text>
    </View>
  );
};

BidCard.propTypes = {
  product: PropTypes.object.isRequired,
  currentBid: PropTypes.number.isRequired,
  onBid: PropTypes.func.isRequired
};

const styles = StyleSheet.create({
  container: { padding: 16 }
});

export default BidCard;
```

### API Integration
- Centralize API calls in `services/api.js`
- Handle loading/error states
- Implement retry logic
- Cache responses where appropriate

---

## Testing Strategy

### Backend
- Unit tests for services (Jest)
- Integration tests for handlers
- Mock DynamoDB with local instance
- Target: 80% coverage

### Frontend
- Component tests (React Native Testing Library)
- Integration tests for screens
- E2E tests for critical flows (Detox)
- Target: 70% coverage

### Infrastructure
- Terraform validation
- AWS resource verification
- Cost estimation checks

---

## Documentation Requirements

Every feature must include:
1. **Specification** in `specs/`
2. **Implementation** in appropriate directory
3. **Tests** in `tests/`
4. **Documentation** update in `docs/`
5. **Kiro log** entry

---

## Code Review Checklist

- [ ] Follows specification
- [ ] Passes all tests
- [ ] Within Free Tier limits
- [ ] Documented in code
- [ ] Updated relevant docs
- [ ] Logged Kiro usage
- [ ] Commit message follows convention
- [ ] No secrets in code
- [ ] Error handling present
- [ ] Accessible (frontend)

---

## Security Guidelines

- Never commit AWS credentials
- Use IAM roles for Lambda
- Validate all user inputs
- Sanitize database queries
- Use HTTPS only
- Implement rate limiting
- Log security events

---

## Performance Guidelines

### Backend
- Lambda cold start < 1s
- API response < 500ms
- DynamoDB queries optimized
- Minimize Lambda package size

### Frontend
- App launch < 2s
- Screen transitions < 300ms
- Image optimization
- Lazy loading for lists

---

## Deployment

### Environments
- `dev` - Development testing
- `prod` - Production (competition demo)

### Process
1. Merge to `develop`
2. Run full test suite
3. Deploy to `dev` environment
4. Manual QA testing
5. Merge to `main`
6. Deploy to `prod`
7. Tag release

---

## Competition-Specific

### Before Each Commit
```bash
# 1. Log Kiro usage
./scripts/kiro-log.sh log "Type" "Description"

# 2. Update session notes
# Edit .sessions/YYYY-MM-DD.md

# 3. Commit with proper message
git commit -m "feat(area): description"
```

### Weekly Review
- Update `docs/kiro-usage.md`
- Review Free Tier usage
- Update project description if needed
- Prepare social media updates
