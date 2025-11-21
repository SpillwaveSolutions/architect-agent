#!/usr/bin/env bash
# log-start.sh - Start a new logging session (OpenCode Plugin version)
# Replacement for Claude Code's /log-start slash command
# Part of architect-agent hybrid logging protocol v3.0
# Complies with SPEC.md Section 2.5 file naming conventions

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

# Get task description from argument or use default
TASK_DESC="${1:-session}"

# Sanitize task description for filename (alphanumeric, hyphens, underscores only)
TASK_SAFE=$(echo "$TASK_DESC" | sed 's/[^a-zA-Z0-9_-]/_/g' | tr '[:upper:]' '[:lower:]')

# Create logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Generate timestamp following SPEC.md Section 2.5: YYYY_MM_DD-HH_MM
TIMESTAMP=$(date +%Y_%m_%d-%H_%M)

# Generate log filename following SPEC.md Section 2.5: log-YYYY_MM_DD-HH_MM-description.md
LOG_FILE="$LOG_DIR/log-${TIMESTAMP}-${TASK_SAFE}.md"

# Create the log file with session header
cat > "$LOG_FILE" <<EOF
# Logging Session: ${TASK_DESC}

**Started:** $(date '+%Y-%m-%d %H:%M:%S')
**Log File:** ${LOG_FILE}

---

EOF

# Write the log file path to current_log_file.txt
# This tells the OpenCode plugin where to write logs
echo "$LOG_FILE" > "$CURRENT_LOG_FILE"

# Confirm to user
echo "✅ Logging session started"
echo "📝 Log file: $LOG_FILE"
echo "🔌 OpenCode plugin will now automatically log to this file"
echo ""
echo "Usage: ./debugging/scripts/log-start.sh [task-description]"
echo "To complete the session, run: ./debugging/scripts/log-complete.sh"
