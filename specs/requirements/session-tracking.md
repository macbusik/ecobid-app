# Session Tracking System

## Overview
Automated daily session tracking for documenting development progress and generating social media content.

## Requirements

### Functional Requirements

**FR-1: Automatic Session Detection**
- System checks local date/time on interaction start
- Creates new session file if date changes (format: `YYYY-MM-DD.md`)
- Appends to existing file if same day

**FR-2: Session File Structure**
```markdown
# Session: YYYY-MM-DD

## Session 1 (HH:MM - HH:MM)
### What I Built
- Task/feature completed

### Commits
- hash: description

### Notes
- Technical decisions, blockers

## Session 2 (HH:MM - HH:MM)
[Same structure for multiple sessions in one day]

## Social Media Post
[Aggregated daily summary]

## Next Steps
- Planned tasks
```

**FR-3: Git Integration**
- Session files stored in `.sessions/` directory
- Directory excluded via `.gitignore`
- Script can extract commit info from git log

**FR-4: Session Management**
- Start session: Record timestamp, create/append to daily file
- End session: Record end timestamp, prompt for summary
- Multiple sessions per day consolidated in one file

### Non-Functional Requirements

**NFR-1: Privacy**
- Session files never committed to repository
- Local-only storage for candid progress notes

**NFR-2: Simplicity**
- Single script execution to manage sessions
- Minimal user input required

**NFR-3: Portability**
- Works on Linux/macOS/Windows
- No external dependencies beyond git

## Acceptance Criteria

- [ ] Script detects current date automatically
- [ ] Creates new file only when date changes
- [ ] Appends multiple sessions to same daily file
- [ ] Extracts git commits since last session
- [ ] Generates social media post template
- [ ] All session files excluded from git

## Technical Design

**Script Location**: `scripts/session.sh` or `scripts/session.py`

**Commands**:
- `./scripts/session.sh start` - Begin new session
- `./scripts/session.sh end` - End session with summary
- `./scripts/session.sh status` - Show current session info
