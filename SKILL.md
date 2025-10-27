---
name: architect-agent
description: Use this skill ONLY when user explicitly requests: (1) "write instructions for code agent" or "create instructions", (2) "this is a new architect agent, help me set it up" or "initialize architect agent workspace", or (3) "grade the code agent's work". This skill creates delegation instructions, initializes architect agent workspaces with required directory structure, and grades completed work.
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

**DO NOT trigger this skill for:**
- General architecture discussions
- Brainstorming or exploration
- Reading/analyzing existing code
- Research tasks
- Any other architect agent activities

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

**Example Multi-Tenant Setup:**
- Architect Agent 1: `/Users/user/architect/project-a` → Code Agent: `/Users/user/projects/project-a`
- Architect Agent 2: `/Users/user/architect/project-b` → Code Agent: `/Users/user/projects/project-b`

Each architect agent maintains its own `instructions/`, `grades/`, `human/`, and `ticket/` directories while referencing different code agent workspaces.

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
- **Ticket ID**: e.g., peak121, proj456
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

## Reference Documents

All detailed protocols available in `references/`:

1. **`logging_protocol.md`** - Real-time logging with tee, practical examples
2. **`testing_protocol.md`** - Progressive testing schedule, coverage requirements
3. **`grading_rubrics.md`** - 6-category grading system, automatic caps
4. **`agent_specialization.md`** - Agent categories, common mistakes, grading impact
5. **`resilience_protocol.md`** - Error recovery, verification, deviation protocol
6. **`file_naming.md`** - Naming patterns, matching rules, examples
7. **`git_pr_management.md`** - Commit format, PR creation, documentation

## Quick Reference Checklist

### Creating Instructions:
- [ ] Start with logging requirements (use tee examples)
- [ ] Include testing protocol section
- [ ] Specify required agents (qa-enforcer, change-explainer, etc.)
- [ ] Add resilience and recovery instructions
- [ ] Define clear success criteria (10-15 items)
- [ ] Use correct file naming pattern
- [ ] Create BOTH human summary AND detailed instructions

### Grading Work:
- [ ] Read code agent's logs thoroughly
- [ ] Verify every action has verification
- [ ] Check testing was performed progressively
- [ ] Confirm agents used correctly
- [ ] Score all 6 categories using rubric
- [ ] Apply automatic caps if warranted
- [ ] Document evidence from logs/code
- [ ] Use matching description for grade filename

## Key Principles

1. **Logging is mandatory** - No logs = Max C+ grade
2. **Test after every change** - Not just at end
3. **Coverage >= 60%** - Non-negotiable
4. **Right agent for the job** - qa-enforcer ≠ doc creation
5. **CI/CD must be tested** - Config without testing = incomplete
6. **Verify every action** - Commands, resources, configurations
7. **Document deviations** - OK to deviate if justified

## Progressive Disclosure

This skill uses three-level loading:
1. **Metadata (always loaded)**: When to use this skill
2. **SKILL.md (loaded when invoked)**: Core workflows and quick reference
3. **References (loaded as needed)**: Detailed protocols when architect agent needs specifics

This design minimizes context usage while maintaining comprehensive guidance.
