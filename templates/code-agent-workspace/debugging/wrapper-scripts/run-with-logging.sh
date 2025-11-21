#!/bin/bash
# Main wrapper: Execute command with automated logging

# Check for active log session
if [ ! -f debugging/current_log_file.txt ]; then
    echo "❌ Error: No active logging session. Run ./debugging/scripts/log-start.sh first." >&2
    exit 1
fi

# Get command to execute
COMMAND="$*"

if [ -z "$COMMAND" ]; then
    echo "Usage: $0 <command> [args...]" >&2
    exit 1
fi

# Log the tool call (pre-execution)
./debugging/wrapper-scripts/log-tool-call.sh "Bash" "$COMMAND"

# Create temporary file for output capture
TEMP_OUTPUT=$(mktemp)

# Execute the command and capture output
# Use 'command' prefix to bypass any shell function wrappers
set +e  # Don't exit on error
eval "command $COMMAND" > "$TEMP_OUTPUT" 2>&1
EXIT_CODE=$?
set -e

# Log the result and output (post-execution)
./debugging/wrapper-scripts/log-tool-result.sh "$EXIT_CODE" "$TEMP_OUTPUT"

# Display output to terminal
command cat "$TEMP_OUTPUT"

# Clean up
rm -f "$TEMP_OUTPUT"

# Exit with the same code as the wrapped command
exit $EXIT_CODE
