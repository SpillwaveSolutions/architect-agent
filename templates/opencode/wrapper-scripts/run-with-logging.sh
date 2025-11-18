#!/bin/bash
#
# run-with-logging.sh - Generic command wrapper with automated logging
#
# Usage: ./run-with-logging.sh <command> [args...]
#
# This script wraps any command to provide automated logging equivalent to
# Claude Code's tool-call-hook and tool-result-hook. It:
# 1. Logs the command before execution (tool-call)
# 2. Executes the command and captures output
# 3. Logs the result with exit code (tool-result)
#
# Part of the architect-agent hybrid logging protocol v2.0 for OpenCode.

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# Path to current log file reference
CURRENT_LOG_FILE_PATH="debugging/current_log_file.txt"

# ============================================================================
# Helper Functions
# ============================================================================

# Get current timestamp in HH:MM:SS format (matches Claude Code hooks)
get_timestamp() {
    date +%H:%M:%S
}

# Get active log file path, or return empty if no active session
get_log_file() {
    if [ ! -f "$CURRENT_LOG_FILE_PATH" ]; then
        echo ""
        return
    fi

    local log_file
    log_file=$(cat "$CURRENT_LOG_FILE_PATH" | tr -d '\n' | tr -d '\r')

    if [ -z "$log_file" ]; then
        echo ""
        return
    fi

    echo "$log_file"
}

# Append text to log file (fails silently if logging not possible)
log_entry() {
    local log_file="$1"
    local text="$2"

    if [ -z "$log_file" ]; then
        return 0
    fi

    echo -e "$text" >> "$log_file" 2>/dev/null || true
}

# ============================================================================
# Main Logic
# ============================================================================

# Check if command provided
if [ $# -eq 0 ]; then
    echo "Error: No command specified" >&2
    echo "Usage: $0 <command> [args...]" >&2
    exit 1
fi

# Get active log file
LOG_FILE=$(get_log_file)

# If no active log session, just execute command normally
if [ -z "$LOG_FILE" ]; then
    exec "$@"
fi

# Log command before execution (tool-call-hook equivalent)
TIMESTAMP=$(get_timestamp)
COMMAND_STR="$*"

log_entry "$LOG_FILE" "\n---\n[$TIMESTAMP] TOOL: Bash"
log_entry "$LOG_FILE" "COMMAND: $COMMAND_STR"

# Create temporary file for capturing output
TEMP_OUTPUT=$(mktemp)
trap "rm -f $TEMP_OUTPUT" EXIT

# Execute command and capture output + exit code
set +e
"$@" 2>&1 | tee "$TEMP_OUTPUT"
EXIT_CODE=${PIPESTATUS[0]}
set -e

# Log result after execution (tool-result-hook equivalent)
TIMESTAMP=$(get_timestamp)

if [ $EXIT_CODE -eq 0 ]; then
    # Success
    log_entry "$LOG_FILE" "[$TIMESTAMP] RESULT: ✅ Success"
else
    # Failure
    log_entry "$LOG_FILE" "[$TIMESTAMP] RESULT: ❌ Failed (exit code: $EXIT_CODE)"
fi

# Log output if not too large
OUTPUT_SIZE=$(wc -c < "$TEMP_OUTPUT")
MAX_OUTPUT_SIZE=10000  # 10KB max

if [ $OUTPUT_SIZE -gt 0 ]; then
    if [ $OUTPUT_SIZE -le $MAX_OUTPUT_SIZE ]; then
        log_entry "$LOG_FILE" "OUTPUT:"
        cat "$TEMP_OUTPUT" >> "$LOG_FILE" 2>/dev/null || true
    else
        log_entry "$LOG_FILE" "OUTPUT: (truncated - ${OUTPUT_SIZE} bytes, showing first 10KB)"
        head -c $MAX_OUTPUT_SIZE "$TEMP_OUTPUT" >> "$LOG_FILE" 2>/dev/null || true
        log_entry "$LOG_FILE" "\n... (output truncated)"
    fi
fi

log_entry "$LOG_FILE" "---"

# Exit with same code as wrapped command
exit $EXIT_CODE
