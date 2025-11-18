# OpenCode Logger Plugin

This plugin provides automated logging for the architect-agent hybrid logging protocol v2.0 in OpenCode environments.

## Purpose

Equivalent to Claude Code's `hooks.json`, this plugin automatically logs:
- User messages when submitted
- Tool calls before execution (tool name + parameters)
- Tool results after execution (success/failure + output)

## Installation

### 1. Copy Plugin to Code Agent Workspace

```bash
# From architect agent workspace
cp -r templates/opencode/plugins/logger <code-agent-workspace>/.opencode/plugins/
```

### 2. Enable Plugin in opencode.json

In your code agent workspace, create or edit `.opencode/opencode.json`:

```json
{
  "plugins": ["./plugins/logger"]
}
```

### 3. Verify Installation

The plugin will activate automatically when OpenCode starts. Check for:
- No error messages on startup
- Logs appear in `debugging/logs/` when log session is active

## How It Works

### Log Session Detection

The plugin checks for an active log session by reading:
```
debugging/current_log_file.txt
```

If this file exists and contains a valid log file path, the plugin logs to that file. Otherwise, it fails silently (no logging, no errors).

### Lifecycle Hooks

| OpenCode Hook | Claude Code Equivalent | Logs |
|--------------|----------------------|------|
| `onUserMessage` | `user-prompt-submit-hook` | User prompts with timestamp |
| `onToolCalled` | `tool-call-hook` | Tool name + parameters before execution |
| `onToolResult` | `tool-result-hook` | Success/failure + output after execution |

### Log Format

Matches Claude Code hooks format exactly:

```markdown
[14:23:45] 💬 USER MESSAGE: Please implement the API endpoint

---
[14:23:47] TOOL: Bash
PARAMS: command="task test"
[14:23:49] RESULT: ✅ Success
OUTPUT:
test_database.py::test_connection PASSED
47 passed in 2.34s
---
```

## Token Savings

This plugin enables the **automated layer** of hybrid logging protocol v2.0:
- **0 tokens** consumed for automated logging
- **60-70% reduction** in total logging tokens vs manual-only approach
- Same token efficiency as Claude Code hooks

## Complementary Manual Logging

The plugin handles **automated** logging (Layer 1). For **manual** contextual logging (Layer 2), use:

```bash
# Log high-value decisions and rationale
./debugging/scripts/log-decision.sh decision "Using async approach for performance"
./debugging/scripts/log-decision.sh rationale "Reduces API latency by 60%"
```

See `references/opencode_logging_protocol.md` for complete protocol details.

## Troubleshooting

### Plugin Not Logging

**Check 1: Plugin enabled in opencode.json?**
```bash
cat .opencode/opencode.json | grep logger
# Should show: "plugins": ["./plugins/logger"]
```

**Check 2: Active log session?**
```bash
cat debugging/current_log_file.txt
# Should show path like: debugging/logs/20250117_143000_implement_api.md
```

**Check 3: Log file writable?**
```bash
LOG_FILE=$(cat debugging/current_log_file.txt)
touch "$LOG_FILE"  # Should succeed without error
```

### OpenCode Version Compatibility

This plugin requires OpenCode with plugin API support. If you're using an older version, consider:
- Upgrading OpenCode to the latest version
- Using wrapper scripts instead (see `templates/opencode/wrapper-scripts/`)

## Differences from Claude Code Hooks

| Feature | Claude Code Hooks | OpenCode Plugin |
|---------|------------------|----------------|
| **Configuration** | `.claude/hooks.json` | `.opencode/opencode.json` |
| **Language** | Bash commands | TypeScript |
| **Environment vars** | `$TOOL_NAME`, `$TOOL_PARAMS`, etc. | Function parameters |
| **Execution** | Shell subprocess | In-process function call |
| **Performance** | ~5-10ms overhead | <1ms overhead |

The OpenCode plugin is **faster** and **more type-safe** than bash hooks, while maintaining identical log format and behavior.

## See Also

- `references/opencode_logging_protocol.md` - Complete logging protocol
- `references/opencode_setup_guide.md` - Full setup instructions
- `templates/opencode/wrapper-scripts/` - Alternative bash-based approach
- `docs/testing/opencode-integration-test/` - Integration tests
