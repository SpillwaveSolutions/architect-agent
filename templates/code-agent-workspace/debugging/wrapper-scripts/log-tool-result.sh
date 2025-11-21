#!/bin/bash
# Post-execution logging: Log the result and output after executing

EXIT_CODE="$1"
OUTPUT_FILE="$2"

# Get active log file
if [ ! -f debugging/current_log_file.txt ]; then
    echo "❌ Error: No active logging session. Run log-start.sh first." >&2
    exit 1
fi

LOG_FILE=$(command cat debugging/current_log_file.txt | command tr -d '\n')
TIMESTAMP=$(command date +"%H:%M:%S")

# Determine result based on exit code
if [ "$EXIT_CODE" -eq 0 ]; then
    RESULT="✅ Success"
else
    RESULT="❌ Failed (exit code: $EXIT_CODE)"
fi

# Log result and output
command cat >> "$LOG_FILE" <<EOF
[$TIMESTAMP] RESULT: $RESULT
OUTPUT:
$(command cat "$OUTPUT_FILE")
---
EOF
