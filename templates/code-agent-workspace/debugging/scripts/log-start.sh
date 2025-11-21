#!/usr/bin/env bash
# log-start.sh - Start a new logging session (OpenCode Plugin version)
# Replacement for Claude Code's /log-start slash command
# Part of architect-agent hybrid logging protocol v2.0

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# Directory where logs are stored
LOG_DIR="debugging/logs"

# File that tracks the current active log file
CURRENT_LOG_FILE="debugging/current_log_file.txt"

# ============================================================================
# Main Script
# ============================================================================

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Generate log filename with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/session_${TIMESTAMP}.log"

# Create the log file with session header
cat > "$LOG_FILE" <<EOF
================================================================================
LOGGING SESSION STARTED
================================================================================
Timestamp: $(date '+%Y-%m-%d %H:%M:%S')
Session ID: ${TIMESTAMP}
Log File: ${LOG_FILE}
================================================================================

EOF

# Write the log file path to current_log_file.txt
# This tells the OpenCode plugin where to write logs
echo "$LOG_FILE" > "$CURRENT_LOG_FILE"

# Confirm to user
echo "✅ Logging session started"
echo "📝 Log file: $LOG_FILE"
echo "🔌 OpenCode plugin will now automatically log to this file"
echo ""
echo "To complete the session, run: ./debugging/scripts/log-complete.sh"
