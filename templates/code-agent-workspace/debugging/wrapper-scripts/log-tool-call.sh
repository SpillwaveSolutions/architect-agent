#!/bin/bash
# Pre-execution logging: Log the tool call before executing

TOOL_NAME="$1"
shift
COMMAND="$*"

# Get active log file
if [ ! -f debugging/current_log_file.txt ]; then
    echo "❌ Error: No active logging session. Run log-start.sh first." >&2
    exit 1
fi

LOG_FILE=$(command cat debugging/current_log_file.txt | command tr -d '\n')
TIMESTAMP=$(command date +"%H:%M:%S")

# Log tool call
command cat >> "$LOG_FILE" <<EOF

---
[$TIMESTAMP] TOOL: $TOOL_NAME
PARAMS: command="$COMMAND"
EOF
