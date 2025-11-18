#!/bin/bash
# OpenCode Wrapper Script - run-with-logging.sh
# Full documentation: references/opencode_logging_protocol.md

set -euo pipefail

CURRENT_LOG_FILE_PATH="debugging/current_log_file.txt"

get_log_file() {
    [ ! -f "$CURRENT_LOG_FILE_PATH" ] && echo "" && return
    cat "$CURRENT_LOG_FILE_PATH" | tr -d '\n\r'
}

LOG_FILE=$(get_log_file)
[ -z "$LOG_FILE" ] && exec "$@"

TIMESTAMP=$(date +%H:%M:%S)
echo -e "\n---\n[$TIMESTAMP] TOOL: Bash" >> "$LOG_FILE" 2>/dev/null || true
echo "COMMAND: $*" >> "$LOG_FILE" 2>/dev/null || true

TEMP_OUTPUT=$(mktemp)
trap "rm -f $TEMP_OUTPUT" EXIT

set +e
"$@" 2>&1 | tee "$TEMP_OUTPUT"
EXIT_CODE=${PIPESTATUS[0]}
set -e

TIMESTAMP=$(date +%H:%M:%S)
if [ $EXIT_CODE -eq 0 ]; then
    echo "[$TIMESTAMP] RESULT: ✅ Success" >> "$LOG_FILE" 2>/dev/null || true
else
    echo "[$TIMESTAMP] RESULT: ❌ Failed (exit code: $EXIT_CODE)" >> "$LOG_FILE" 2>/dev/null || true
fi

[ -s "$TEMP_OUTPUT" ] && cat "$TEMP_OUTPUT" >> "$LOG_FILE" 2>/dev/null || true
echo "---" >> "$LOG_FILE" 2>/dev/null || true

exit $EXIT_CODE
