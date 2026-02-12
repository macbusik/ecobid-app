#!/bin/bash

export TZ="Europe/Warsaw"

KIRO_LOG_DIR="docs/kiro-logs"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
LOG_FILE="$KIRO_LOG_DIR/$DATE.log"

mkdir -p "$KIRO_LOG_DIR"

log_interaction() {
    local action="$1"
    local description="$2"
    
    echo "[$TIME] $action: $description" >> "$LOG_FILE"
}

generate_summary() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "No Kiro interactions logged today"
        exit 0
    fi
    
    echo "=== Kiro Usage Summary for $DATE ==="
    echo ""
    echo "Total interactions: $(wc -l < "$LOG_FILE")"
    echo ""
    echo "Activity log:"
    cat "$LOG_FILE"
}

case "$1" in
    log)
        log_interaction "$2" "$3"
        echo "✓ Logged: $2"
        ;;
    summary)
        generate_summary
        ;;
    *)
        echo "Usage: $0 {log|summary} [action] [description]"
        echo ""
        echo "Examples:"
        echo "  $0 log 'Code Generation' 'Created Lambda handler for bidding'"
        echo "  $0 log 'Specification' 'Generated API spec for user authentication'"
        echo "  $0 summary"
        exit 1
        ;;
esac
