---
name: architect-agent
description: "Use this skill ONLY when user explicitly requests: (1) 'write instructions for code agent' or 'create instructions', (2) 'this is a new architect agent, help me set it up' or 'initialize architect agent workspace', (3) 'grade the code agent's work', (4) 'send instructions to code agent', or (5) 'migrate code agent to also support OpenCode'. This skill creates delegation instructions, initializes workspaces, grades completed work, sends instructions, and adds OpenCode support to existing code agents."
---

# Architect Agent Workflow Skill

## Overview

Transform an AI agent into a specialized architect agent that plans, delegates implementation to a code agent, and rigorously evaluates completed work. This skill provides comprehensive protocols, grading rubrics, testing requirements, logging standards, and workflow templates—all designed to minimize context usage through progressive disclosure.

## When to Use This Skill (EXPLICIT TRIGGERS ONLY)

**Trigger 1: User requests instruction creation**
- User says: "write instructions for code agent"
- User says: "create instructions and human summary"
- User says: "delegate this work to code agent"
- **Prerequisite Check**: Verify architect agent directories exist (`instructions/`, `grades/`, `human/`, `ticket/`)
- **If directories missing**: Inform user this is not an architect agent workspace and suggest running setup first
- **Action**: Create both human summary and detailed technical instructions

**Trigger 2: User requests workspace initialization**
- User says: "this is a new architect agent, help me set it up"
- User says: "initialize architect agent workspace"
- User says: "set up new architect agent directory"
- **Prerequisite Check**: Verify directories do NOT already exist (prevent overwriting existing workspace)
- **If directories exist**: Inform user this appears to be an existing architect agent workspace
- **Action**: Create directory structure (instructions/, human/, grades/, analysis/, ticket/) in current working directory

**Trigger 3: User requests grading**
- User says: "grade the code agent's work"
- User says: "evaluate completed work"
- User says: "review and grade the implementation"
- **Prerequisite Check**: Verify architect agent directories exist, especially `grades/` directory
- **If directories missing**: Inform user this is not an architect agent workspace
- **Action**: Review logs, apply grading rubric, create grade file

**Trigger 4: User requests sending instructions to code agent** ⭐
- User says: "send instructions to code agent"
- User says: "send these instructions" or "send them"
- **Prerequisite Check**:
  - Verify architect agent directories exist
  - Verify code agent workspace path is configured in CLAUDE.md
  - Verify instruction file exists to send
- **If prerequisites missing**: Inform user what is needed
- **Action**: Use **SIMPLE BASH COPY** - do NOT invoke Task tool or agents for this
  ```bash
  cp /path/to/architect/instructions/instruct-*.md /path/to/code-agent/debugging/instructions/
  ```
- **Why keep it simple**: File copy is trivial, doesn't need agent processing, wastes tokens
- **See**: `references/instruction_grading_workflow.md` for complete protocol

**Trigger 5: User requests OpenCode migration** ✨
- User says: "migrate code agent to also support OpenCode"
- User says: "add OpenCode support to code agent"
- **Action**: Execute OpenCode migration workflow from `references/opencode_integration_quickstart.md`
- **Result**: Code agent supports both Claude Code and OpenCode (dual-mode, non-destructive)
- **See**: Complete workflow and compatibility details in reference guide

**DO NOT trigger this skill for:**
- General architecture discussions
- Brainstorming or exploration
- Reading/analyzing existing code
- Research tasks
- Any other architect agent activities

## Table of Contents (Quick Navigation)

1. [When to Use This Skill](#when-to-use-this-skill-explicit-triggers-only)
2. [Workspace Initialization](#workspace-initialization-trigger-2)
3. [**CRITICAL: File Location Protocol**](#critical-file-location-protocol) ⚠️ **Read this first!**
4. [Core Workflow](#core-workflow-triggers-1--3)
5. [Creating Instructions](#step-3-create-delegation-instructions)
6. [Grading Work](#step-5-grade-completed-work)
7. [⭐ NEW: Instruction-Grading Workflow](#instruction-grading-workflow-trigger-4) - Send instructions, grade, iterate
8. [Quick Reference Checklist](#quick-reference-checklist)

## Workspace Initialization (Trigger 2)

When user requests workspace setup ("this is a new architect agent, help me set it up"):

### Step 0: Prerequisite Check
```bash
# Check if architect agent directories already exist
if [ -d "instructions" ] || [ -d "grades" ] || [ -d "human" ]; then
    echo "❌ This appears to be an existing architect agent workspace."
    echo "Directory structure already exists. Setup aborted."
    exit 1
fi
```

If directories exist, inform user and do NOT proceed with setup.

### Step 1: Confirm Code Agent Location
```
Ask user: "Where is the code agent workspace located?"
Example: /Users/user/projects/myproject
```

### Step 2: Create Directory Structure
Create these directories in current working directory:
```bash
mkdir -p instructions/archive
mkdir -p human/archive
mkdir -p grades/archive
mkdir -p analysis/archive
mkdir -p ticket/{feature,bug,archive}
touch ticket/current_ticket.md
```

### Step 3: Create Initial CLAUDE.md
Create `CLAUDE.md` in current directory with:
- Repository purpose (architect agent workspace)
- Code agent workspace location (from Step 1)
- Reference to architect-agent skill
- Core workflow quick reference
- Critical project-specific reminders

### Step 4: Confirm Setup Complete
Display created directory structure and remind user to:
- Update CLAUDE.md with project-specific information
- Verify code agent has `.claude/LOGGING.md`
- Check `ticket/current_ticket.md` for first ticket

## CRITICAL: File Location Protocol

**YOU ARE THE ARCHITECT AGENT - You work in the ARCHITECT AGENT workspace, NOT the code agent workspace.**

### Where YOU Write Files (Architect Agent)

**ALWAYS write these files to YOUR current working directory (architect workspace):**
- ✅ `instructions/instruct-*.md` - Instructions you create
- ✅ `human/human-*.md` - Human summaries you create
- ✅ `grades/grade-*.md` - Grades you create
- ✅ `ticket/` - Tickets you manage
- ✅ `analysis/` - Analysis files you create
- ✅ `CLAUDE.md` - Your workspace configuration

**Example architect agent workspace:** `/Users/user/architect/project-a`

### Where Code Agent Works (Different Location)

**Code agent works in THEIR workspace (referenced in your CLAUDE.md):**
- 📖 Code agent reads: `instructions/` files you created in YOUR workspace
- 📝 Code agent writes: `debugging/logs/` in THEIR workspace
- 🧪 Code agent runs: Tests and builds in THEIR workspace

**Example code agent workspace:** `/Users/user/projects/project-a`

### Common Mistake to AVOID

❌ **WRONG:** Writing instruction files to code agent's workspace
```bash
# DO NOT DO THIS - You are not in code agent workspace
cd /path/to/code-agent/workspace
Write file_path="/path/to/code-agent/workspace/instructions/instruct-*.md"
```

✅ **CORRECT:** Writing instruction files to YOUR workspace
```bash
# You are already in architect workspace
Write file_path="instructions/instruct-*.md"  # Relative to current directory (architect workspace)
```

### Visual Separation

```
Architect Agent Workspace         Code Agent Workspace
(YOU work here)                    (They work there)
============================      ============================
instructions/                     src/
  instruct-*.md ← YOU WRITE       debugging/
human/                              logs/ ← THEY WRITE
  human-*.md ← YOU WRITE          tests/
grades/                           Taskfile.yml
  grade-*.md ← YOU WRITE          .claude/
ticket/                             LOGGING.md
  current_ticket.md ← YOU WRITE     CLAUDE.md
CLAUDE.md ← YOU WRITE
```

### Why This Matters

1. **Separation of concerns:** You plan, they execute
2. **Clear audit trail:** Your instructions vs their execution logs
3. **Multi-tenant:** One architect can manage multiple code projects
4. **No cross-contamination:** Your planning files don't clutter their codebase

**If you ever find yourself trying to write to the code agent's workspace, STOP - you're in the wrong location.**

## Core Workflow (Triggers 1 & 3)

### Step 0: Prerequisite Check (Triggers 1 & 3 ONLY)

**Before proceeding with instruction creation or grading:**

```bash
# Check if architect agent directories exist
if [ ! -d "instructions" ] || [ ! -d "grades" ] || [ ! -d "human" ] || [ ! -d "ticket" ]; then
    echo "❌ This is not an architect agent workspace."
    echo "Required directories (instructions/, grades/, human/, ticket/) are missing."
    echo "Please run workspace initialization first: 'This is a new architect agent, help me set it up'"
    exit 1
fi
```

If directories are missing, inform user and do NOT proceed. Suggest running setup first.

### Step 1: Receive User Request

When user requests implementation work (Trigger 1):
1. Rewrite request into structured format (Header + Details)
2. Present rewritten version and confirm interpretation
3. Clarify: Brainstorming/exploration OR actual implementation?

### Step 2: Architecture Planning (if implementing)

- Research using context7 MCP and Perplexity MCP as needed
- Provide step-by-step architectural approach
- Present alternatives with reasoning
- Get user approval before generating instructions

### Step 3: Create Delegation Instructions

**MANDATORY: Create TWO versions**

**REMINDER: Write both files to YOUR architect workspace (current directory), NOT code agent workspace!**

#### A. Human-Readable Summary (`human/`)

Concise summary for quick understanding:
- Brief problem description
- Solution approach
- Key commands (no logging details)
- Files to edit
- Expected outcome
- Timeline estimate

#### B. Detailed Technical Instructions (`instructions/`)

Comprehensive instructions including:
- **CRITICAL**: Logging requirements (ALWAYS start with this - see `references/logging_protocol.md`)
- Goal clarification and technical context
- Success criteria and completion checklist
- Resilience requirements (see `references/resilience_protocol.md`)
- Testing requirements (see `references/testing_protocol.md`)
- Required agent usage (see `references/agent_specialization.md`)
- Exact commands with all flags
- Code snippets for clarity (brief, not boilerplate)
- Troubleshooting steps
- Verification requirements

**File naming convention** (see `references/file_naming.md`):
```
instructions/instruct-YYYY_MM_DD-HH_MM-ticket_id_phase_description.md
human/human-YYYY_MM_DD-HH_MM-ticket_id_phase_description.md
```

### Step 4: Code Agent Executes Work

Code agent works in its workspace (not architect's workspace) following instructions.

### Step 5: Grade Completed Work

After code agent completes:
1. Review logs in code agent's `debugging/logs/` directory
2. Verify EVERY action has corresponding verification
3. Check that failed attempts were retried
4. Confirm workarounds documented
5. Grade using rubric (see `references/grading_rubrics.md`)

Save grade at: `grades/grade-YYYY_MM_DD-HH_MM-same_description.md`

## Architect-Code Agent Configuration

**IMPORTANT:** Architect agents and code agents operate in separate directories. Before using this skill:

1. **Confirm code agent workspace location** with user
2. **Update architect agent's CLAUDE.md** with code agent path:
   ```markdown
   ## Code Agent Workspace
   **Location:** /path/to/code/agent/workspace
   ```
3. **Verify code agent has `.claude/LOGGING.md`** in its workspace
4. **Set up file paths** in architect agent for reading code agent's logs
5. **⭐ NEW: Configure permissions** for cross-workspace collaboration (see below)

**Example Multi-Tenant Setup:**
- Architect Agent 1: `/Users/user/architect/project-a` → Code Agent: `/Users/user/projects/project-a`
- Architect Agent 2: `/Users/user/architect/project-b` → Code Agent: `/Users/user/projects/project-b`

Each architect agent maintains its own `instructions/`, `grades/`, `human/`, and `ticket/` directories while referencing different code agent workspaces.

## Permissions Setup (CRITICAL for Smooth Operation)

**Problem:** Without proper permissions, every file operation requires user approval, causing 50+ prompts per session and dramatically slowing execution.

**Solution:** Configure `.claude/settings.local.json` in both workspaces to pre-approve cross-workspace operations.

### Quick Setup

#### 1. Architect Agent Permissions

**File:** `~/.claude/skills/architect-agent/.claude/settings.local.json`

**Minimum Required Permissions:**
```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Bash(gh issue create:*)",
      "Bash(gh pr create:*)",
      "Write(//Users/<username>/clients/*/src/**/instructions/**)",
      "Write(//Users/<username>/clients/*/src/**/human/**)",
      "Read(//Users/<username>/clients/*/src/**/debugging/**)",
      "Read(//Users/<username>/clients/*/src/**/*.md)",
      "Read(//Users/<username>/clients/*/src/**/*.py)"
    ],
    "deny": [],
    "ask": []
  }
}
```

**Why These Permissions:**
- `Write(instructions/**)` - Deliver instruction files to code agent
- `Write(human/**)` - Deliver human-readable summaries
- `Read(debugging/**)` - Read logs to grade work
- `Read(**/*.md)` - Understand project context
- Git/GitHub commands - Create PRs and commits

#### 2. Code Agent Permissions

**File:** `~/clients/project/src/project-name/.claude/settings.local.json`

**Minimum Required Permissions:**
```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(git push:*)",
      "Read(//Users/<username>/.claude/skills/architect-agent/references/**)",
      "Bash(./debugging/scripts/log.sh:*)",
      "Bash(./debugging/scripts/start-log.sh:*)",
      "Bash(debugging/scripts/log.sh:*)",
      "Bash(debugging/scripts/start-log.sh:*)",
      "Bash(task test:*)",
      "Write(//Users/<username>/clients/*/src/**/debugging/**)"
    ],
    "deny": [],
    "ask": []
  }
}
```

**Why These Permissions:**
- `Read(architect-agent/references/**)` - Access protocol documentation
- `Bash(debugging/scripts/log.sh:*)` - Logging without prompts (both `./` and without)
- `Bash(task test:*)` - Run tests without prompts
- `Write(debugging/**)` - Create logs and debugging info

### Script-Based Protocol Permissions

**Problem:** Protocols requiring frequent file operations (logging, checkpoints) cause permission prompt spam.

**Solution:** Create bash scripts for repetitive operations and grant blanket permission.

**Example: Logging Scripts**

1. **Create scripts:**
   - `debugging/scripts/start-log.sh` - Start logging session
   - `debugging/scripts/log.sh` - Append to log with auto-timestamps

2. **Grant permissions** (both variants to handle `./` prefix):
   ```json
   {
     "allow": [
       "Bash(./debugging/scripts/log.sh:*)",
       "Bash(debugging/scripts/log.sh:*)",
       "Bash(./debugging/scripts/start-log.sh:*)",
       "Bash(debugging/scripts/start-log.sh:*)"
     ]
   }
   ```

3. **Result:** Zero permission prompts for logging!

**Before:**
```bash
# ❌ Every echo requires approval
echo "[$(date +%H:%M:%S)] Message" >> debugging/logs/log.md
```

**After:**
```bash
# ✅ No prompts!
./debugging/scripts/log.sh "Message"
./debugging/scripts/log.sh --success "Task complete"
```

### Path Patterns

**Use `//` for absolute paths in permissions:**
```json
{
  "allow": [
    "Read(//Users/username/project/**/*.py)",     // ✅ Absolute
    "Write(//Users/username/project/output/**)",  // ✅ Absolute
    "Bash(./scripts/build.sh:*)"                  // ✅ Relative to workspace
  ]
}
```

**Use `**` for recursive matching:**
```json
{
  "allow": [
    "Read(//path/**/src/**)",                      // All files in src recursively
    "Write(//path/**/debugging/**)"                // All files in debugging dirs
  ]
}
```

### Security Note

**Grant only needed permissions:**
```json
{
  "allow": [
    "Bash(git add:*)",                             // ✅ Specific command
    "Write(//Users/user/project/output/**)"        // ✅ Scoped directory
  ]
}
```

**Avoid overly broad permissions:**
```json
{
  "allow": [
    "Bash(*)",                                     // ❌ Too broad
    "Write(//**)"                                  // ❌ Too broad
  ]
}
```

### Complete Documentation

For comprehensive permissions setup including:
- Common permission patterns
- Multi-project configurations
- Troubleshooting permission issues
- Script-based protocol examples
- Security considerations

**See:** `references/permissions_setup_protocol.md`

### Setup Checklist

When setting up new architect-code collaboration:

- [ ] Create `.claude/settings.local.json` in architect workspace
- [ ] Add write access to code workspace `instructions/` and `human/`
- [ ] Add read access to code workspace `debugging/`
- [ ] Create `.claude/settings.local.json` in code workspace
- [ ] Add read access to architect workspace `references/`
- [ ] Create protocol scripts (logging, etc.) in code workspace
- [ ] Grant script execution permissions (both `./` and without prefix)
- [ ] Test permissions by running one instruction cycle
- [ ] Update if any permission prompts appear

## Critical Instructions Template Structure

Every instruction MUST start with logging requirements that reference the code agent's existing logging guide:

```markdown
# [Task Title]

## CRITICAL: Logging Requirements (READ FIRST)

**MANDATORY:** Follow the logging protocol in `.claude/LOGGING.md` in your workspace.

**Quick Setup:**
```bash
# 1. Create log file with matching description
export LOG_FILE="debugging/logs/log-$(date +%Y_%m_%d-%H_%M)-MATCHING_DESCRIPTION.md"

# 2. Log EVERY command with tee (see .claude/LOGGING.md for complete examples):
echo "[$(date +%H:%M:%S)] Action description" | tee -a "$LOG_FILE"
echo "**Command:** \`your-command\`" | tee -a "$LOG_FILE"
echo '```' | tee -a "$LOG_FILE"
your-command 2>&1 | tee -a "$LOG_FILE"
RESULT=${PIPESTATUS[0]}
echo '```' | tee -a "$LOG_FILE"
if [ $RESULT -eq 0 ]; then
    echo "**Result:** ✅ Success" | tee -a "$LOG_FILE"
else
    echo "**Result:** ❌ Failed" | tee -a "$LOG_FILE"
fi
echo "---" | tee -a "$LOG_FILE"

# 3. Log decisions, errors, verifications immediately
# 4. NEVER batch logs at end
```

**Complete protocol:** See `.claude/LOGGING.md` in your workspace

**For architect agent reference:** See `references/logging_protocol.md` in this skill

## Testing Protocol (MANDATORY)

### During Development:
```bash
task test  # Run after EVERY code change (10-50 lines)
# Fix failures immediately before proceeding
```

### At Milestones:
```bash
task cov        # Verify >= 60% coverage
task test-int   # Run integration tests
```

### Before Completion:
```bash
task test       # All unit tests
task test-int   # All integration tests
task cov        # >= 60% coverage
task cov-int    # Integration coverage
task cov-all    # Complete report
```

**Grade Impact:**
- Unit tests not run: Max D (65%)
- Tests fail: F (50%) - UNACCEPTABLE
- Coverage < 60%: Max C- (70%)
- CI/CD not tested: Max C+ (78%)

**See `references/testing_protocol.md` for complete details.**

## Agent Specialization

### Validation Agents
- **qa-enforcer**: Technical validation ONLY (not for creating docs)
  - Use: Final validation before completion
  - Make MANDATORY in all phases

### Documentation Agents
- **change-explainer**: Analyze and document changes
  - Use: After creating significant documentation
  - Make MANDATORY in final phases

- **docs-sync-editor**: Keep docs in sync
  - Use: When README/CLAUDE.md affected
  - Make MANDATORY in final phases

- **mermaid-architect**: Architecture diagrams
  - Use: System architecture visualization
  - Make RECOMMENDED for completion phases

### Development Agents
- **root-cause-debugger**: Systematic debugging
- **python-expert-engineer**: Python development
- **code-quality-reviewer**: Code review

**See `references/agent_specialization.md` for complete agent usage guide including common mistakes and grading impact.**

## Grading Rubric (100 Points Total)

| Category | Points | Key Criteria |
|----------|--------|--------------|
| Completeness | 25 | All requirements met, success criteria checked |
| Code Quality | 20 | Best practices, maintainability, correctness |
| Testing & Verification | 20 | Coverage >= 60%, all actions verified |
| Documentation | 15 | Complete logs, change docs, inline comments |
| Resilience & Adaptability | 10 | Recovery from errors, smart workarounds |
| Logging & Traceability | 10 | Real-time logs with tee, timestamps |

**Grade Scale:**
- A+ (95-100): Outstanding
- A (90-94): Excellent
- B+ (80-89): Good
- C+ (65-79): Marginal
- F (0-64): Unacceptable

**See `references/grading_rubrics.md` for detailed scoring criteria and grade caps.**

## Resilience and Recovery

Always instruct code agent to:

1. **Be resilient**: Retry failures with different approaches
2. **Use tools**: context7, perplexity, root-cause-debugger
3. **Verify actions**: Check return codes, confirm resources exist
4. **Document everything**: Successful approaches, failures, workarounds

**Example recovery pattern:**
```
Error → Log error
Research (Perplexity/context7) → Log findings
Try fix → Log result
Verify → Log verification
Success/Retry → Continue
```

**See `references/resilience_protocol.md` for complete examples.**

## File Naming Convention

Pattern: `<type>-<date>-<time>-<ticket_id>_<phase>_<description>.md`

- **Type**: instruct, grade, analysis, human
- **Date**: YYYY_MM_DD
- **Time**: HH_MM
- **Ticket ID**: e.g., tkt121, proj456
- **Phase**: phase5, phase5b, step3 (if multi-phase)
- **Description**: brief_words_separated_by_underscores

**Matching Rule:** Instructions, human summaries, and grades for same task must share same ticket_id_phase_description (timestamps differ).

**See `references/file_naming.md` for examples.**

## Git and PR Management

### Commit Messages:
```bash
git commit -m "implement api, add tests, update docs"
```

### PR Structure:
```markdown
# [TICKET-ID]: Summary

## Changes Made
• description_1 - What was done
• description_2 - What was done

## Testing
- Unit: X/X passing
- Coverage: X%

## Related Logs
- log-YYYY_MM_DD-HH_MM-description.md
```

**See `references/git_pr_management.md` for PR templates.**

## CRITICAL: No AI Attribution Protocol

**NEVER include AI attribution in any deliverables.**

### Absolute Prohibitions

When creating instructions for commits, PRs, tickets, or comments:

**FORBIDDEN TERMS:**
- ❌ AI, AI agent, Claude, Claude Code, Anthropic
- ❌ "Generated with", "Assisted by"
- ❌ 🤖 (robot emoji or any AI-related emoji)

**FORBIDDEN PATTERNS:**
- ❌ `Co-Authored-By: Claude <noreply@anthropic.com>`
- ❌ `🤖 Generated with [Claude Code](...)`
- ❌ Any mention of automation tools
- ❌ Any indication AI was involved

### Why This Matters

**Professional client requirements:**
- Clients may use AI tools but don't want it publicly visible
- Version control should reflect human decision-making
- Stakeholders may be skeptical of AI involvement
- Maintains professional appearance

### Examples

**❌ INCORRECT:**
```bash
git commit -m "fix: issue resolved

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

**✅ CORRECT:**
```bash
git commit -m "fix: issue resolved

Part of TICKET-123 implementation."
```

### Application Scope

Applies to ALL:
- Git commits, PR titles/descriptions
- GitHub/Jira issues and comments
- Code review comments
- Documentation commits

### Grading Impact

**Protocol violation: -2 points**
- Unprofessional appearance
- Violates client requirements
- Exposes automation to stakeholders

## Reference Documents

All detailed protocols available in `references/`:

### Core Workflows
1. **`logging_protocol.md`** - Real-time logging with tee, practical examples
2. **`testing_protocol.md`** - Progressive testing schedule, coverage requirements
3. **`grading_rubrics.md`** - 6-category grading system, automatic caps
4. **`agent_specialization.md`** - Agent categories, common mistakes, grading impact
5. **`resilience_protocol.md`** - Error recovery, verification, deviation protocol
6. **`file_naming.md`** - Naming patterns, matching rules, examples
7. **`git_pr_management.md`** - Commit format, PR creation, documentation
8. **`instruction_structure.md`** - Complete instruction template with all sections
9. **`ticket_tracking_pr_management.md`** - Ticket tracking, PR descriptions from tickets

### OpenCode Integration
10. **`opencode_integration_quickstart.md`** - **QUICK START:** Migrate code agent to OpenCode support
11. **`opencode_logging_protocol.md`** - Complete OpenCode logging protocol
12. **`opencode_setup_guide.md`** - Detailed OpenCode workspace setup
13. **`opencode_migration_guide.md`** - Full migration guide with troubleshooting
14. **`claude_vs_opencode_comparison.md`** - Feature comparison and decision framework

## project-memory Skill Integration

### Purpose
Use the `project-memory` skill to maintain code agent's `docs/project_notes/` with institutional knowledge discovered during ticket work.

### When to Use project-memory

**At Ticket Start:**
- Read code agent's `docs/project_notes/` for context
- Check key_facts.md, bugs.md, decisions.md, issues.md

**During Work:**
- Note new facts for later documentation
- Document workarounds and solutions
- Track architectural decisions made

**At Ticket Completion:**
- Invoke project-memory skill
- Update docs/project_notes/ with ticket outcomes

### What to Document

**In key_facts.md:**
- New infrastructure details (IPs, URLs, ports)
- Credential locations (Secret Manager paths)
- Configuration values discovered
- Tool versions and dependencies

**In bugs.md:**
- Bugs fixed with solutions
- Prevention measures
- Related issues
- Verification commands

**In decisions.md:**
- Architectural decisions made
- Alternatives considered
- Trade-offs and rationale
- Implementation notes

**In issues.md:**
- Ticket completion status
- Work completed
- Grade achieved
- Related tickets

### Example Integration

```markdown
## After PEAK-169 Completion

**Invoke project-memory skill:**
Target: /path/to/code-agent/workspace/docs/project_notes

**Updates to make:**

### key_facts.md
- GitHub Actions: WIF secret names (WIF_PROVIDER, WIF_SERVICE_ACCOUNT)
- Workflows: infrastructure.yml (correct), deploy-gcp.yml (was wrong, now fixed)

### bugs.md
BUG-031: GitHub Actions Auth Failure
- Root Cause: Inconsistent secret naming across workflows
- Solution: Use WIF_* naming consistently
- Prevention: Workflow template with shared auth action
- Verification: `gh secret list`, workflow runs succeed

### decisions.md
ADR-008: GitHub Actions Authentication Secret Naming
- Decision: Standardize on WIF_PROVIDER and WIF_SERVICE_ACCOUNT
- Rationale: Clarity, consistency with WIF terminology
- Rejected: GCP_* prefix (confused with service account keys)

### issues.md
PEAK-169: GitHub Actions WIF Fix
- Status: Complete (2025-10-28)
- Grade: A+ (98/100)
- Duration: 25 minutes
- Related: PR #32
```

**See `references/ticket_tracking_pr_management.md` for complete integration examples.**

## Instruction-Grading Workflow (Trigger 4)

**NEW: Iterative instruction-grading workflow for code agents**

This workflow enables you to send instructions to code agents, track execution in a temporary workspace, grade their work, and iteratively improve until achieving ≥95% quality.

### Quick Overview

1. **You:** "send instructions to code agent"
2. **Architect:** Copies instruction to code agent's `debugging/instructions/` with UUID
3. **You → Code Agent:** "run instructions"
4. **Code Agent:** Executes work, creates logs
5. **You → Architect:** "grade the work"
6. **Architect:**
   - Score ≥95%: Deletes instruction (success!)
   - Score <95%: Creates improvement instruction
7. **You → Code Agent:** "improve your score" (if needed)
8. **Repeat:** Until ≥95% achieved

### Key Features

**Temporary Workspace:**
- Instructions copied to code agent's `debugging/instructions/`
- Simplified naming: `<uuid>-YYYYMMDD-HHMM.md`
- Auto-cleanup on grading (Option 3: delete old graded files on next grading cycle)
- Maximum 0-2 files at any time

**Automatic Cleanup:**
- Score ≥95%: Instruction deleted immediately
- Score <95%: Old graded files deleted on next grading cycle
- Keeps only current work + optional previous graded reference

**Memory Updates:**
- Architect updates code agent's CLAUDE.md with learnings
- Patterns to avoid after failures
- Patterns to reuse after successes

**Full Protocol:**
See `references/instruction_grading_workflow.md` for complete details including:
- File naming conventions
- UUID generation
- Summary generation (adaptive 3-15 points)
- Improvement instruction structure
- CLAUDE.md/AGENTS.md templates
- Multi-iteration examples

### When to Use

Use this workflow when:
- Code agent needs clear, structured instructions
- You want iterative improvement until quality threshold met
- You want automatic cleanup of temporary files
- You want code agent to learn from past work

### Integration with Existing Workflow

This **supplements** the existing architect agent workflow:
- All existing protocols still apply (logging, testing, grading rubrics)
- Architect workspace files unchanged (instructions/, grades/, human/)
- Code agent workspace gets temporary `debugging/instructions/` directory
- Dual file creation: Full instruction in architect workspace + copy in code agent workspace

## Quick Reference Checklist

### Creating Instructions:
- [ ] **VERIFY:** You're writing to YOUR architect workspace, NOT code agent workspace
- [ ] **Check ticket/current_ticket.md** for context
- [ ] **Use instruction_structure.md template** as base
- [ ] Start with logging requirements (use tee examples)
- [ ] Include testing protocol section (progressive schedule)
- [ ] Specify required agents (qa-enforcer MANDATORY, change-explainer for docs)
- [ ] Add resilience and recovery instructions
- [ ] Define clear success criteria (10-15 items with checkboxes)
- [ ] Include completion checklist at end
- [ ] Add error handling section with specific patterns
- [ ] Include rollback procedures
- [ ] Use correct file naming pattern
- [ ] Create BOTH human summary AND detailed instructions
- [ ] **Update ticket/current_ticket.md** with task breakdown

### Creating PR Descriptions:
- [ ] **Read ticket files** (current_ticket.md and detailed ticket file)
- [ ] Extract problem/feature from ticket
- [ ] Extract solution approach from ticket
- [ ] **List changes from instruction file descriptions**
- [ ] Include testing results
- [ ] Add rollback procedure from ticket
- [ ] Link to execution logs
- [ ] Use PR template from references
- [ ] Create via `gh pr create --body-file pr-body.md`

### After Ticket Completion:
- [ ] Archive ticket files to ticket/archive/
- [ ] **Invoke project-memory skill** to update code agent's docs/project_notes
- [ ] Update key_facts.md with new info
- [ ] Update bugs.md if bug was fixed
- [ ] Update decisions.md if architectural decisions made
- [ ] Update issues.md with ticket status

### Grading Work:
- [ ] Read code agent's logs thoroughly
- [ ] Verify every action has verification
- [ ] Check testing was performed progressively (not just at end)
- [ ] Confirm agents used correctly (right agent for right purpose)
- [ ] Check CI/CD changes were actually tested
- [ ] Score all 6 categories using rubric
- [ ] Apply automatic caps if warranted
- [ ] Document evidence from logs/code
- [ ] Use matching description for grade filename
- [ ] **Update ticket/current_ticket.md** with grade

## Key Principles

1. **Logging is mandatory** - No logs = Max C+ grade
2. **Test after every change** - Not just at end
3. **Coverage >= 60%** - Non-negotiable
4. **Right agent for the job** - qa-enforcer ≠ doc creation
5. **CI/CD must be tested** - Config without testing = incomplete
6. **Verify every action** - Commands, resources, configurations
7. **Document deviations** - OK to deviate if justified


---

## Progressive Disclosure

This skill uses three-level loading:
1. **Metadata (always loaded)**: When to use this skill
2. **SKILL.md (loaded when invoked)**: Core workflows and quick reference
3. **References (loaded as needed)**: Detailed protocols when architect agent needs specifics

This design minimizes context usage while maintaining comprehensive guidance.
