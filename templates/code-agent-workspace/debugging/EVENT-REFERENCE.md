# OpenCode Plugin Event Reference

**Plugin Version:** SPEC.md v4.1 Compliant
**OpenCode Version:** v1.0.85+
**Location:** `.opencode/plugin/logger.js`
**Token Cost:** 0 (all background logging)
**File Naming:** Follows SPEC.md Section 2.5 (`log-YYYY_MM_DD-HH_MM-description.md`)

This document provides a comprehensive reference for all 13 event handlers implemented in the automatic logging plugin.

---

## Overview

The OpenCode logger plugin provides **60-70% token savings** through automatic background logging. It tracks events across 7 major categories without requiring manual logging commands.

### Event Categories

1. **Tool Events** (2 handlers) - Tool calls and results
2. **Session Events** (6 handlers) - Session lifecycle
3. **File Events** (2 handlers) - File modifications
4. **Command Events** (1 handler) - User commands
5. **Permission Events** (2 handlers) - Security permissions
6. **TUI Events** (3 handlers) - Terminal UI interactions
7. **TODO Events** (1 handler) - Task progression

---

## Configuration

### Log Levels

**ESSENTIAL Mode** (minimal logging):
- Logs only critical events: sessions, file edits, permissions, commands, tool calls
- Recommended for production or token-sensitive environments
- Excludes: TUI events, file watcher, session.idle

**VERBOSE Mode** (comprehensive logging):
- Logs all 13 event types
- Recommended for development and debugging
- Provides complete session audit trail

### Environment Variables

```bash
# Set log level
export OPENCODE_LOG_LEVEL=VERBOSE  # or ESSENTIAL

# Disable specific event categories
export OPENCODE_LOG_TUI=false              # Disable TUI events
export OPENCODE_LOG_FILE_WATCHER=false     # Disable file watcher
```

---

## 1. Tool Events

### `tool.execute.before`

**Purpose:** Captures tool calls before execution
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[14:23:45] TOOL: Read
PARAMS: file_path="/path/to/Service.java"
```

**Use Cases:**
- Track which tools the agent is using
- Audit file access patterns
- Debug tool call sequences

### `tool.execute.after`

**Purpose:** Captures tool results after execution
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry (Success):**
```markdown
[14:23:46] RESULT: ✅ Success
OUTPUT:
public class Service {
    // ... (truncated)
---
```

**Example Log Entry (Error):**
```markdown
[14:23:46] RESULT: ❌ Error
ERROR: ENOENT: no such file or directory
---
```

---

## 2. Session Events

### `session.created`

**Purpose:** Marks the beginning of a new OpenCode session
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[10:00:25] SESSION: Created
SESSION_ID: abc123
---
```

### `session.updated`

**Purpose:** Tracks changes to session metadata
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[14:30:12] SESSION: Updated
CHANGES: title="Implement authentication", additions=45, deletions=12, files=3
---
```

### `session.deleted`

**Purpose:** Marks session termination
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[16:45:30] SESSION: Deleted
DURATION: 3600s
FINAL_STATUS: completed
---
```

### `session.status`

**Purpose:** Tracks session state transitions
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[14:35:20] SESSION: Status → active
---
```

### `session.error`

**Purpose:** Captures session-level errors
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[15:10:45] SESSION: Error
ERROR: Failed to connect to model API: Network timeout after 30s
---
```

### `session.idle`

**Purpose:** Marks session entering idle state
**Log Level:** VERBOSE only

**Example Log Entry:**
```markdown
---
[15:30:00] SESSION: Idle
---
```

---

## 3. File Events

### `file.edited`

**Purpose:** Tracks files modified by the agent
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[14:25:30] FILE: Edited
PATH: src/main/java/com/example/Service.java
ACTION: modified
---
```

### `file.watcher.updated`

**Purpose:** Tracks external file system changes
**Log Level:** VERBOSE only (configurable)

**Example Log Entry:**
```markdown
---
[14:26:15] FILE: Watcher Update
PATH: src/main/java/com/example/Service.java
EVENT: changed
SOURCE: external
---
```

**Configuration:**
```bash
# Disable file watcher logging
export OPENCODE_LOG_FILE_WATCHER=false
```

---

## 4. Command Events

### `command.executed`

**Purpose:** Tracks user-initiated commands
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[14:40:20] COMMAND: /compact
ARGS: {"model":"claude-3.7-sonnet"}
---
```

---

## 5. Permission Events

### `permission.replied`

**Purpose:** Tracks responses to permission requests
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[14:45:10] PERMISSION: Replied
ACTION: Bash(rm -rf build/)
RESPONSE: approved
REASON: User explicitly approved
---
```

### `permission.updated`

**Purpose:** Tracks changes to permission rules
**Log Level:** Always logged (ESSENTIAL)

**Example Log Entry:**
```markdown
---
[14:46:00] PERMISSION: Updated
ACTION: Bash(git push:*)
STATUS: always_allow
TARGET: *.git repositories
---
```

---

## 6. TUI Events

### `tui.prompt.append`

**Purpose:** Tracks prompts sent to the agent
**Log Level:** VERBOSE only (configurable)

**Example Log Entry:**
```markdown
---
[14:50:30] TUI: Prompt
TEXT: Please implement user authentication with JWT tokens
---
```

**Configuration:**
```bash
# Disable TUI event logging
export OPENCODE_LOG_TUI=false
```

### `tui.command.execute`

**Purpose:** Tracks TUI commands
**Log Level:** VERBOSE only

**Example Log Entry:**
```markdown
---
[14:52:15] TUI: Command → open_settings
ARGS: {"section":"permissions"}
---
```

### `tui.toast.show`

**Purpose:** Tracks toast notifications shown to user
**Log Level:** VERBOSE only

**Example Log Entry:**
```markdown
---
[14:55:00] TUI: Toast [WARNING]
MESSAGE: File watcher detected external changes to 3 files
---
```

---

## 7. TODO Events

### `todo.updated`

**Purpose:** Tracks task progression and TODO list changes
**Log Level:** Always enabled (configurable)

**Example Log Entry:**
```markdown
---
[15:00:30] TODO: completed
TASK: Implement JWT authentication service
REMAINING: 4
---
```

---

## Token Impact Analysis

### Per-Session Token Costs (30-command session):

**Without Logging (Baseline):**
- Agent work: ~5,000 tokens
- Total: ~5,000 tokens

**With Manual Logging (v1.0):**
- Agent work: ~5,000 tokens
- Manual logging overhead: ~3,000 tokens
- Total: ~8,000 tokens (+60% overhead)

**With Automated Logging (v3.0 - Current):**
- Agent work: ~5,000 tokens
- Automated logging overhead: ~750 tokens
- Total: ~5,750 tokens (+15% overhead)
- **Savings: 2,250 tokens per session (75% reduction in logging overhead)**

---

## Grading Impact

**How Event Logging Affects Scores:**

| Event Type | Grading Category | Points Impact | Required? |
|------------|------------------|---------------|-----------|
| **Tool calls** | Logging & Traceability (10 pts) | +8 points if present | ✅ Required |
| **Session events** | Completeness (25 pts) | +2 points | ✅ Required |
| **Permission events** | Security compliance | Audit trail | ⚠️ If applicable |
| **File events** | Completeness (25 pts) | +1 point per file | ✅ Required |

**Scoring Examples:**

**Grade: 97% (Excellent Logging)**
- All tool calls logged via plugin ✅ (+8 pts)
- All sessions tracked ✅ (+2 pts)
- All file edits captured ✅ (+1 pt)
- Permissions audited ✅ (+1 pt)

**Grade: 78% (Poor Logging - No Plugin)**
- Manual logging incomplete ⚠️ (-8 points)
- Sessions not tracked ❌ (-2 points)
- File edits missing ❌ (-1 point)

---

## Best Practices

**DO:**
- ✅ Use VERBOSE mode for development
- ✅ Use ESSENTIAL mode for production
- ✅ Verify plugin loads on session start
- ✅ Check logs for automatic entries
- ✅ Combine with manual decision logging

**DON'T:**
- ❌ Disable critical event logging
- ❌ Skip plugin installation
- ❌ Forget to run log-start.sh before sessions
- ❌ Assume plugin replaces all manual logging

---

## Troubleshooting

### Plugin Not Loading

**Check console output:**
```bash
# Look for initialization message
grep "LoggerPlugin: INITIALIZING" ~/.opencode/logs/*
```

**Verify plugin file:**
```bash
ls -la .opencode/plugin/logger.js
# Should exist and be readable
```

### No Automatic Logs

**Check active log pointer:**
```bash
cat debugging/current_log_file.txt
# Should contain path to active log file
```

**Verify log session started:**
```bash
# Must run this before OpenCode session
./debugging/scripts/log-start.sh "task-description"
```

### Incomplete Event Capture

**Check log level:**
```bash
# Set to VERBOSE for maximum coverage
export OPENCODE_LOG_LEVEL=VERBOSE
```

**Verify event handlers registered:**
```bash
# Console output should show:
# "✅ LoggerPlugin: Initialized with 13 event handlers"
```

---

## Related Documentation

- [SPEC.md Section 2.5](../../SPEC.md#25-file-naming-and-correlation-specification) - File naming conventions
- [SPEC.md Section 3.4](../../SPEC.md#34-code-agent-workspace-template) - Template structure
- [SPEC.md Section 6.2](../../SPEC.md#62-opencode-wrapper-architecture) - Wrapper architecture
- [logging_protocol.md](../../references/logging_protocol.md) - Complete logging requirements
- [grading_rubrics.md](../../references/grading_rubrics.md) - How logging affects grades

---

**Last Updated:** 2025-01-21
**Version:** SPEC.md v4.1 Compliant
**Plugin Version:** OpenCode v1.0.85+
**Token Savings:** 60-70%
