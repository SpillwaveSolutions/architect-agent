#!/usr/bin/env bash
# log-complete.sh - Complete a logging session (OpenCode Plugin version)
# Replacement for Claude Code's /log-complete slash command
# Part of architect-agent hybrid logging protocol v3.0
# Complies with SPEC.md Section 2.5 file naming conventions

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

# File that tracks the current active log file
CURRENT_LOG_FILE="debugging/current_log_file.txt"

# ============================================================================
# Main Script
# ============================================================================

# Check if there's an active logging session
if [[ ! -f "$CURRENT_LOG_FILE" ]]; then
    echo "❌ No active logging session found"
    echo "   Run ./debugging/scripts/log-start.sh to start a session"
    exit 1
fi

# Read the active log file path
LOG_FILE=$(cat "$CURRENT_LOG_FILE")

# Check if the log file exists
if [[ ! -f "$LOG_FILE" ]]; then
    echo "⚠️  Warning: Log file not found: $LOG_FILE"
    echo "   Cleaning up session tracking file anyway"
    rm "$CURRENT_LOG_FILE"
    exit 1
fi

# Append session completion footer to the log
cat >> "$LOG_FILE" <<EOF

---

## Session Completed

**Completed:** $(date '+%Y-%m-%d %H:%M:%S')
**Log File:** ${LOG_FILE}

EOF

# Remove the current log file tracker
# This stops the OpenCode plugin from logging
rm "$CURRENT_LOG_FILE"

# Confirm to user
echo "✅ Logging session completed"
echo "📝 Log file saved: $LOG_FILE"
echo "🔌 OpenCode plugin logging stopped"
echo ""
echo "To review the log: cat $LOG_FILE"
echo "To start a new session: ./debugging/scripts/log-start.sh"
