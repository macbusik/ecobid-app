# EcoBid App - 10000AIdeas Competition

Mobile-first bidding application built on AWS Free Tier using spec-driven development.

## Project Structure

```
ecobid-app/
├── specs/                      # Specification-first approach
│   ├── api/                    # OpenAPI/AsyncAPI specifications
│   ├── architecture/           # Architecture Decision Records (ADRs)
│   └── requirements/           # User stories, acceptance criteria
│
├── infrastructure/             # Infrastructure as Code
│   ├── terraform/              # Terraform configurations
│   └── cloudformation/         # CloudFormation templates (AWS native)
│
├── backend/                    # Serverless backend
│   ├── src/
│   │   ├── handlers/           # Lambda function handlers
│   │   ├── models/             # Data models
│   │   ├── services/           # Business logic
│   │   └── utils/              # Shared utilities
│   └── tests/                  # Backend tests
│
├── frontend/                   # Client applications
│   ├── mobile/                 # React Native / Flutter
│   │   ├── src/
│   │   │   ├── components/     # Reusable UI components
│   │   │   ├── screens/        # App screens
│   │   │   ├── services/       # API clients, state management
│   │   │   └── utils/          # Helper functions
│   │   └── tests/
│   └── web/                    # Optional web interface
│
├── docs/                       # Documentation
├── scripts/                    # Deployment & utility scripts
└── .github/workflows/          # CI/CD pipelines
```

## Architecture Principles Met

### 1. Separation of Concerns
- **specs/**: Decouples design from implementation
- **infrastructure/**: Separates infrastructure from application code
- **backend/frontend**: Clear client-server boundary

### 2. Spec-Driven Development
- **specs/api/**: API contracts defined before implementation (OpenAPI)
- **specs/requirements/**: Testable acceptance criteria
- **specs/architecture/**: ADRs document key decisions

### 3. Serverless-First (AWS Free Tier)
- Lambda functions in `backend/src/handlers/`
- API Gateway specs in `specs/api/`
- DynamoDB models in `backend/src/models/`
- S3 for static assets
- Cognito for auth

### 4. Testability
- Separate `tests/` directories
- Service layer isolation enables unit testing
- Handlers remain thin for easy integration testing

### 5. Scalability & Maintainability
- Modular structure supports team growth
- Clear boundaries enable parallel development
- Infrastructure as Code ensures reproducibility

### 6. Mobile-First
- Primary focus on `frontend/mobile/`
- Web interface optional/secondary
- API-first design supports multiple clients

## AWS Free Tier Services (Recommended)

- **API Gateway**: REST/HTTP APIs
- **Lambda**: Serverless compute
- **DynamoDB**: NoSQL database
- **S3**: Static hosting, file storage
- **Cognito**: User authentication
- **CloudWatch**: Logging & monitoring
- **Amplify**: Mobile app deployment (optional)

## Getting Started

1. Define specs in `specs/requirements/` and `specs/api/`
2. Create infrastructure in `infrastructure/`
3. Implement backend handlers based on API specs
4. Build mobile UI consuming the API
5. Deploy via CI/CD pipelines

## Development Workflow

See detailed guidelines:
- **Git Workflow**: `docs/git-workflow.md` - Branching strategy and commit conventions
- **Development Standards**: `docs/development-guidelines.md` - Infrastructure, backend, frontend guidelines
- **Session Tracking**: Use `./scripts/session.sh start|end|status`
- **Kiro Logging**: Use `./scripts/kiro-log.sh log "Type" "Description"`

### Quick Start
```bash
# Start new feature
git checkout develop
git checkout -b feature/backend/my-feature

# Make changes, then commit
git add .
git commit -m "feat(backend): add my feature"
./scripts/kiro-log.sh log "Code Generation" "Created my feature"

# Merge back
git checkout develop
git merge feature/backend/my-feature --no-ff
```
