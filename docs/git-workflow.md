# Git Workflow Guidelines

## Repository Strategy

**Decision**: Monorepo (single repository)

**Rationale**:
- Competition requires "Project Completeness" - easier to demonstrate in one repo
- Simplified documentation and submission process
- Clear development history in one place
- Easier for judges to review

## Branch Strategy

### Main Branches
- `main` - Production-ready code, tagged releases
- `develop` - Integration branch for features

### Feature Branches
Format: `feature/<area>/<description>`

**Areas**:
- `specs` - Specifications and requirements
- `infra` - Infrastructure and AWS resources
- `backend` - Lambda functions, APIs
- `frontend` - Mobile app, UI components
- `docs` - Documentation updates

**Examples**:
```
feature/specs/api-authentication
feature/infra/dynamodb-setup
feature/backend/bidding-handler
feature/frontend/login-screen
```

### Support Branches
- `fix/<description>` - Bug fixes
- `chore/<description>` - Maintenance tasks
- `test/<description>` - Test additions

## Workflow

### 1. Start New Feature
```bash
git checkout develop
git pull origin develop
git checkout -b feature/backend/user-auth
```

### 2. Development
```bash
# Make changes
git add .
git commit -m "feat(backend): implement user authentication handler"

# Log Kiro usage
./scripts/kiro-log.sh log "Code Generation" "Created auth handler"
```

### 3. Merge to Develop
```bash
git checkout develop
git merge feature/backend/user-auth --no-ff
git branch -d feature/backend/user-auth
```

### 4. Release to Main
```bash
git checkout main
git merge develop --no-ff
git tag -a v0.1.0 -m "MVP release"
```

## Commit Message Convention

Format: `<type>(<scope>): <description>`

**Types**:
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `spec` - Specification changes
- `infra` - Infrastructure changes
- `test` - Test additions
- `chore` - Maintenance

**Examples**:
```
feat(backend): add bidding Lambda handler
fix(frontend): resolve login button state
docs(api): update authentication endpoints
spec(requirements): add carbon tracking feature
infra(terraform): configure DynamoDB table
```

## Current Status

**Active Branch**: `main` (will create `develop` next)

**Next Steps**:
1. Create `develop` branch
2. Start feature branches for each area
3. Implement spec-driven workflow
