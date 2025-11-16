#!/bin/bash
# Lightweight decision and rationale logger
# Usage: ./debugging/scripts/log-decision.sh <type> <message>
# Types: decision, rationale, investigation, verification, deviation, milestone

set -e

TYPE="${1:-decision}"
MESSAGE="${2:-}"

if [ -z "$MESSAGE" ]; then
    echo "Usage: ./debugging/scripts/log-decision.sh <type> <message>"
    echo "Types: decision, rationale, investigation, verification, deviation, milestone"
    exit 1
fi

# Get current log file
CURRENT_LOG=$(cat debugging/current_log_file.txt 2>/dev/null)
if [ -z "$CURRENT_LOG" ]; then
    echo "Error: No active log session. Run /log-start first."
    exit 1
fi

TIMESTAMP="[$(date +%H:%M:%S)]"

# Format based on type
case "$TYPE" in
    decision)
        echo -e "\n$TIMESTAMP 🎯 DECISION: $MESSAGE" >> "$CURRENT_LOG"
        ;;
    rationale)
        echo -e "$TIMESTAMP 💭 RATIONALE: $MESSAGE" >> "$CURRENT_LOG"
        ;;
    investigation)
        echo -e "\n$TIMESTAMP 🔍 INVESTIGATION: $MESSAGE" >> "$CURRENT_LOG"
        ;;
    verification)
        echo -e "$TIMESTAMP ✓ VERIFICATION: $MESSAGE" >> "$CURRENT_LOG"
        ;;
    deviation)
        echo -e "\n$TIMESTAMP ⚠️  DEVIATION: $MESSAGE" >> "$CURRENT_LOG"
        ;;
    milestone)
        echo -e "\n$TIMESTAMP 🏁 MILESTONE: $MESSAGE\n---" >> "$CURRENT_LOG"
        ;;
    *)
        echo -e "\n$TIMESTAMP 📝 NOTE: $MESSAGE" >> "$CURRENT_LOG"
        ;;
esac

echo "Logged $TYPE: $MESSAGE"
