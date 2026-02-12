#!/bin/bash

SESSION_DIR=".sessions"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M)
SESSION_FILE="$SESSION_DIR/$DATE.md"
STATE_FILE="$SESSION_DIR/.current"

mkdir -p "$SESSION_DIR"

start_session() {
    if [ ! -f "$SESSION_FILE" ]; then
        cat > "$SESSION_FILE" << EOF
# Session: $DATE

EOF
    fi
    
    SESSION_NUM=$(grep -c "^## Session" "$SESSION_FILE" 2>/dev/null)
    [ -z "$SESSION_NUM" ] && SESSION_NUM=0
    SESSION_NUM=$((SESSION_NUM + 1))
    
    cat >> "$SESSION_FILE" << EOF
## Session $SESSION_NUM ($TIME - )

### What I Built
- 

### Commits
$(git log --oneline --since="today" 2>/dev/null | sed 's/^/- /' || echo "- No commits yet")

### Notes
- 

EOF
    
    echo "$DATE|$SESSION_NUM|$TIME" > "$STATE_FILE"
    echo "✓ Session $SESSION_NUM started at $TIME"
    echo "  File: $SESSION_FILE"
}

end_session() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "✗ No active session"
        exit 1
    fi
    
    read -r SESS_DATE SESS_NUM SESS_START < "$STATE_FILE"
    END_TIME=$(date +%H:%M)
    
    sed -i "s/^## Session $SESS_NUM ($SESS_START - )/## Session $SESS_NUM ($SESS_START - $END_TIME)/" "$SESSION_DIR/$SESS_DATE.md"
    
    rm "$STATE_FILE"
    echo "✓ Session $SESS_NUM ended at $END_TIME"
    echo "  Update your summary in: $SESSION_DIR/$SESS_DATE.md"
}

status() {
    if [ -f "$STATE_FILE" ]; then
        read -r SESS_DATE SESS_NUM SESS_START < "$STATE_FILE"
        echo "Active session: #$SESS_NUM (started $SESS_START)"
        echo "File: $SESSION_DIR/$SESS_DATE.md"
    else
        echo "No active session"
    fi
}

case "$1" in
    start) start_session ;;
    end) end_session ;;
    status) status ;;
    *) 
        echo "Usage: $0 {start|end|status}"
        exit 1
        ;;
esac
