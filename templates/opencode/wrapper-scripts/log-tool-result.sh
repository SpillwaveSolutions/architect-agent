#!/bin/bash
#
# log-tool-result.sh - Log tool result after execution
#
# Usage: ./log-tool-result.sh <exit_code> [output]
#
# This script logs a tool result after execution, equivalent to Claude Code's
# tool-result-hook. It is designed to be used in combination with log-tool-call.sh
# for finer-grained control over logging.
#
# Example:
#   ./log-tool-call.sh "Bash" "command=task test"
#   OUTPUT=$(task test 2>&1)
#   EXIT_CODE=$?
#   ./log-tool-result.sh $EXIT_CODE "$OUTPUT"
#
# Part of the architect-agent hybrid logging protocol v2.0 for OpenCode.

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# Path to current log file reference
CURRENT_LOG_FILE_PATH="debugging/current_log_file.txt"

# Maximum output size to log (10KB)
MAX_OUTPUT_SIZE=10000

# ============================================================================
# Helper Functions
# ============================================================================

# Get current timestamp in HH:MM:SS format
get_timestamp() {
    date +%H:%M:%S
}

# Get active log file path
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

# Append text to log file
log_entry() {
    local log_file="$1"
    local text="$2"

    if [ -z "$log_file" ]; then
        return 0
    fi

    echo -e "$text" >> "$log_file" 2>/dev/null || true
}

# Truncate output if too long
truncate_output() {
    local output="$1"
    local output_length=${#output}

    if [ $output_length -le $MAX_OUTPUT_SIZE ]; then
        echo "$output"
    else
        echo "${output:0:$MAX_OUTPUT_SIZE}"
        echo ""
        echo "... (output truncated - ${output_length} bytes, showing first ${MAX_OUTPUT_SIZE})"
    fi
}

# ============================================================================
# Main Logic
# ============================================================================

# Check if exit code provided
if [ $# -lt 1 ]; then
    echo "Error: Exit code required" >&2
    echo "Usage: $0 <exit_code> [output]" >&2
    exit 1
fi

EXIT_CODE="$1"
shift

# Get output if provided
if [ $# -gt 0 ]; then
    OUTPUT="$*"
else
    OUTPUT=""
fi

# Get active log file
LOG_FILE=$(get_log_file)

# Exit silently if no active log session
if [ -z "$LOG_FILE" ]; then
    exit 0
fi

# Log tool result
TIMESTAMP=$(get_timestamp)

if [ "$EXIT_CODE" -eq 0 ]; then
    # Success
    log_entry "$LOG_FILE" "[$TIMESTAMP] RESULT: ✅ Success"
else
    # Failure
    log_entry "$LOG_FILE" "[$TIMESTAMP] RESULT: ❌ Failed (exit code: $EXIT_CODE)"
fi

# Log output if provided
if [ -n "$OUTPUT" ]; then
    log_entry "$LOG_FILE" "OUTPUT:"
    TRUNCATED_OUTPUT=$(truncate_output "$OUTPUT")
    log_entry "$LOG_FILE" "$TRUNCATED_OUTPUT"
fi

log_entry "$LOG_FILE" "---"

exit 0
