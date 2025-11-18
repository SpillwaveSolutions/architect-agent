#!/bin/bash
#
# log-tool-call.sh - Log tool call before execution
#
# Usage: ./log-tool-call.sh <tool_name> <params...>
#
# This script logs a tool call before execution, equivalent to Claude Code's
# tool-call-hook. It is designed to be used in combination with log-tool-result.sh
# for finer-grained control over logging.
#
# Example:
#   ./log-tool-call.sh "Bash" "command=task test"
#   task test
#   ./log-tool-result.sh $? "$(cat output.txt)"
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

# ============================================================================
# Main Logic
# ============================================================================

# Check if arguments provided
if [ $# -lt 1 ]; then
    echo "Error: Tool name required" >&2
    echo "Usage: $0 <tool_name> [params...]" >&2
    exit 1
fi

TOOL_NAME="$1"
shift

# Combine remaining args as params
if [ $# -gt 0 ]; then
    PARAMS="$*"
else
    PARAMS="(none)"
fi

# Get active log file
LOG_FILE=$(get_log_file)

# Exit silently if no active log session
if [ -z "$LOG_FILE" ]; then
    exit 0
fi

# Log tool call
TIMESTAMP=$(get_timestamp)

log_entry "$LOG_FILE" "\n---"
log_entry "$LOG_FILE" "[$TIMESTAMP] TOOL: $TOOL_NAME"
log_entry "$LOG_FILE" "PARAMS: $PARAMS"

exit 0
