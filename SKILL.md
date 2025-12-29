---
name: architect-agent
description: Coordinates planning, delegation, and evaluation across architect and code agent workspaces. Use when asked to "write instructions for code agent", "initialize architect workspace", "grade code agent work", "send instructions", or "verify code agent setup".
---

# Architect Agent Workflow Skill

Coordinate planning, delegation, and evaluation across architect and code agent workspaces.

## Table of Contents

- [Intent Classification](#intent-classification)
- [Decision Tree](#decision-tree)
- [Resource Loading Policy](#resource-loading-policy)
- [Critical Protocol: File Locations](#critical-protocol-file-locations)
- [Quick Setup](#quick-setup-template-based)
- [DO NOT Trigger For](#do-not-trigger-for)
- [Reference Directory](#reference-directory)
- [Guides Directory](#guides-directory)

## Intent Classification

Route requests based on user intent:

| Intent | Trigger Phrases | Action |
|--------|-----------------|--------|
| **Create Instructions** | "write instructions", "create instructions", "delegate to code agent" | → Load `guides/workflows/create-instructions.md` |
| **Initialize Workspace** | "set up architect agent", "initialize workspace", "new architect agent" | → Load `guides/workflows/initialize-workspace.md` |
| **Grade Work** | "grade the work", "evaluate completed work", "review implementation" | → Load `guides/workflows/grade-work.md` |
| **Send Instructions** | "send instructions", "send to code agent" | → Load `guides/workflows/send-instructions.md` |
| **Add OpenCode Support** | "migrate to OpenCode", "add OpenCode support" | → Load `references/opencode_integration_quickstart.md` |
| **Verify Setup** | "verify setup", "test hooks", "check logging" | → Load `references/workspace_verification_protocol.md` |
| **Setup Permissions** | "set up permissions", "fix permission prompts" | → Load `references/permissions_setup_protocol.md` |
| **Upgrade Workspace** | "upgrade workspace", "migrate to v3.0" | → Load `references/upgrade.md` |

## Decision Tree

```
USER REQUEST
    │
    ├─► "write/create instructions" OR "delegate"
    │   └─► Check: instructions/ dir exists?
    │       ├─► Yes → Load guides/workflows/create-instructions.md
    │       └─► No → Suggest workspace initialization first
    │
    ├─► "set up/initialize" architect workspace
    │   └─► Check: directories DON'T exist?
    │       ├─► Correct → Load guides/workflows/initialize-workspace.md
    │       └─► Exist → Warn: already initialized
    │
    ├─► "grade" OR "evaluate" work
    │   └─► Check: grades/ dir exists?
    │       ├─► Yes → Load guides/workflows/grade-work.md
    │       └─► No → Suggest workspace initialization first
    │
    ├─► "send instructions" to code agent
    │   └─► Load guides/workflows/send-instructions.md
    │       └─► Use simple bash copy (DO NOT spawn agents)
    │
    ├─► "verify" OR "test hooks/plugins"
    │   └─► Load references/workspace_verification_protocol.md
    │
    ├─► "OpenCode" OR "dual-mode"
    │   └─► Load references/opencode_integration_quickstart.md
    │
    ├─► "permissions" OR "settings.local.json"
    │   └─► Load references/permissions_setup_protocol.md
    │
    └─► "upgrade" OR "migrate"
        └─► Load references/upgrade.md
```

## Resource Loading Policy

**Load ONLY when needed:**
- Workflow guides: When intent is classified
- Reference docs: When user needs detailed protocol
- Templates: When creating workspace or files
- Never load all references "just in case"

**Core Resources by Intent:**

| Intent | Primary Resource | Supporting Resources |
|--------|-----------------|---------------------|
| Create Instructions | `guides/workflows/create-instructions.md` | `references/instruction_structure.md`, `references/file_naming.md` |
| Initialize Workspace | `guides/workflows/initialize-workspace.md` | `references/workspace_setup_complete.md` |
| Grade Work | `guides/workflows/grade-work.md` | `references/grading_rubrics.md`, `references/decision_types.md` |
| Send Instructions | `guides/workflows/send-instructions.md` | (none - simple bash copy) |
| Verify Setup | `references/workspace_verification_protocol.md` | `references/pre_work_checklist.md` |
| Setup Permissions | `references/permissions_setup_protocol.md` | - |
| OpenCode Support | `references/opencode_integration_quickstart.md` | `references/opencode_setup_guide.md` |

## Critical Protocol: File Locations

**YOU ARE THE ARCHITECT AGENT - You work in YOUR workspace, NOT the code agent workspace.**

| What | Where YOU Write | Where Code Agent Works |
|------|----------------|----------------------|
| Instructions | `YOUR_WORKSPACE/instructions/` | Reads from `debugging/instructions/` |
| Human Summaries | `YOUR_WORKSPACE/human/` | N/A |
| Grades | `YOUR_WORKSPACE/grades/` | N/A |
| Logs | N/A | Writes to `THEIR_WORKSPACE/debugging/logs/` |

**If you find yourself writing to code agent's workspace, STOP.**

## Quick Setup (Template-Based)

For fastest setup, use templates:

```bash
cd ~/.claude/skills/architect-agent/templates/

# Create code agent workspace
./setup-workspace.sh code-agent ~/projects/my-code-agent

# Create architect workspace
./setup-workspace.sh architect ~/projects/my-architect \
    --code-agent-path ~/projects/my-code-agent
```

**Time:** <5 minutes
**See:** `templates/README.md`

## DO NOT Trigger For

- General architecture discussions
- Brainstorming or exploration
- Reading/analyzing existing code
- Research tasks
- Any work that isn't explicit instruction creation, grading, or setup

## Reference Directory

All detailed protocols are in `references/`:

| Reference | Purpose |
|-----------|---------|
| `instruction_structure.md` | Complete instruction file template |
| `grading_rubrics.md` | 6-category grading criteria |
| `decision_types.md` | decision, rationale, investigation, verification, deviation, milestone |
| `pre_work_checklist.md` | Code agent pre-work verification |
| `testing_protocol.md` | Progressive testing requirements |
| `logging_protocol.md` | Hybrid logging v2.0 details |
| `permissions_setup_protocol.md` | Cross-workspace permissions |
| `workspace_verification_protocol.md` | Setup verification procedure |
| `opencode_integration_quickstart.md` | Dual-mode (Claude Code + OpenCode) |
| `file_naming.md` | Timestamp and naming conventions |

## Guides Directory

Step-by-step workflows in `guides/workflows/`:

| Guide | Trigger |
|-------|---------|
| `create-instructions.md` | "write instructions for code agent" |
| `grade-work.md` | "grade the code agent's work" |
| `send-instructions.md` | "send instructions to code agent" |
| `initialize-workspace.md` | "set up architect agent workspace" |

---