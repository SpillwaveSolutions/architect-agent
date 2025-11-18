# Architect Agent Skill

A Claude Code skill that enables you to act as an **Architect Agent** that delegates work to a **Code Agent** (Claude, Cursor, GitHub Copilot CLI, or any AI coding assistant) while maintaining human-in-the-loop oversight and control.

## What This Skill Does

This skill transforms how you work with AI coding assistants by giving you a structured way to:

1. **Create detailed instructions** for AI coding agents
2. **Review and grade completed work** against clear rubrics
3. **Maintain comprehensive logs** of all decisions and changes
4. **Track multi-phase projects** with consistent naming and organization
5. **Stay informed and involved** throughout the entire development process

## Why This Matters: Human-in-the-Loop Control

### See What AI Agents Are Actually Doing

When you use Claude Code, Cursor, GitHub Copilot CLI, or other AI assistants, they often work autonomously—making decisions, writing code, and modifying files. This skill gives you **visibility and control** by:

- **Creating explicit instructions**: You define what needs to be done before the AI starts work
- **Reviewing all changes**: You grade and validate the AI's work after completion
- **Maintaining audit trails**: Every decision, command, and change is logged in real-time
- **Enforcing quality standards**: Clear rubrics ensure the AI meets your expectations

### Feel More Involved and Knowledgeable

Instead of simply asking an AI to "fix the bug" or "add a feature" and hoping for the best, this skill helps you:

- **Understand the full scope** of work before it begins
- **Track progress** through structured logging and checkpoints
- **Learn from the process** by reviewing detailed logs of decisions and rationale
- **Maintain context** across multiple work sessions and phases
- **Stay in control** even when delegating complex tasks to AI agents

### The Three Key Components

1. **Instructions** (`instructions/instruct-*.md`)
   - Clear, detailed specifications you create for the Code Agent
   - Includes requirements, constraints, and success criteria
   - Forces you to think through the work before delegating

2. **Logs** (`debugging/logs/log-*.md`)
   - Real-time capture of all commands, outputs, and decisions
   - Shows you exactly what the AI did and why
   - Creates a searchable audit trail for learning and debugging

3. **Grades** (`grades/grade-*.md`)
   - Your evaluation of the completed work
   - Structured rubrics ensure consistent quality
   - Provides feedback loop for improving future instructions

## Use Cases

### Perfect for:
- **Learning** how AI agents approach complex problems
- **Auditing** AI-generated code changes in production systems
- **Teaching** others how to effectively work with AI assistants
- **Managing** large multi-phase projects with AI assistance
- **Debugging** when AI agents make unexpected decisions
- **Compliance** scenarios requiring detailed change documentation

### Example Workflow

```bash
# 1. You create instructions
/architect-setup
# Write detailed instructions for adding authentication

# 2. Code Agent (Claude/Copilot/etc) executes the work
# - Follows your instructions
# - Logs every decision and command
# - Produces working code

# 3. You grade the completed work
/grade
# Review logs, test functionality, assign scores
# Understand what changed and why
```

### ⭐ NEW: Iterative Instruction-Grading Workflow

Send instructions directly to code agents and iterate until achieving 95%+ quality:

```bash
# 1. Architect creates and sends instructions
You → Architect: "send instructions to code agent"
Architect: Copies to code agent's debugging/instructions/ with UUID
           Shows 10-point summary

# 2. Code agent executes
You → Code Agent: "run instructions"
Code Agent: Implements features, creates logs
            Signals: "instructions completed, ready for grading"

# 3. Architect grades the work
You → Architect: "grade the work"
Architect: Reviews logs, grades against rubric

# If score ≥95%: Success! Instruction deleted, work complete
# If score <95%: Creates improvement instruction

# 4. Code agent improves (if needed)
You → Code Agent: "improve your score"
Code Agent: Implements targeted fixes
            Signals: "improvements completed, ready for re-grading"

# 5. Repeat grading until ≥95% achieved
```

**Key benefits:**
- **Automatic cleanup**: Old graded files deleted on next grading cycle
- **Iterative improvement**: Clear feedback until quality threshold met
- **Learning retention**: Architect updates code agent's CLAUDE.md with patterns
- **Temporary workspace**: `debugging/instructions/` stays clean (max 0-2 files)

## Key Features

### File Naming Convention
All files use consistent naming for easy tracking:
```
<type>-<date>-<time>-<ticket_id>_<phase>_<description>.md
```

Example:
```
instructions/instruct-2025_10_26-14_30-tkt123_phase2_add_authentication.md
debugging/logs/log-2025_10_26-14_30-tkt123_phase2_add_authentication.md
grades/grade-2025_10_26-16_45-tkt123_phase2_add_authentication.md
```

### Comprehensive Documentation

The skill includes detailed protocols for:
- **Agent Specialization**: When to use specific AI agents (qa-enforcer, change-explainer, etc.)
- **Testing Requirements**: Mandatory test coverage and quality checks
- **Git/PR Management**: Creating pull requests with complete context
- **Logging Protocol**: Real-time capture of all commands and outputs
- **Grading Rubrics**: Objective criteria for evaluating work quality

## Getting Started

### Three Ways to Use This Skill

1. **Initialize Workspace** (when starting new agent-delegated work)
   ```
   /architect-setup
   ```
   Creates the directory structure and templates

2. **Create Instructions** (when delegating work to a Code Agent)
   ```
   "Write instructions for implementing user authentication"
   ```
   Generates a structured instruction file

3. **Grade Work** (after Code Agent completes work)
   ```
   "Grade the authentication implementation work"
   ```
   Reviews logs and code, generates grade report

## Permissions Setup (IMPORTANT)

**Problem:** Without permissions configured, you'll face 50+ approval prompts per session, dramatically slowing AI agent collaboration.

**Solution:** Configure `.claude/settings.local.json` in both architect and code agent workspaces.

### Quick Setup

#### 1. Architect Agent Workspace

Create `~/.claude/skills/architect-agent/.claude/settings.local.json`:

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
      "Read(//Users/<username>/clients/*/src/**/debugging/**)"
    ],
    "deny": [],
    "ask": []
  }
}
```

**Replace `<username>` with your actual username.**

**Why:** Allows architect agent to write instructions, read logs, and manage git without prompts.

#### 2. Code Agent Workspace

Create `.claude/settings.local.json` in your code project:

```json
{
  "permissions": {
    "allow": [
      "Bash(git add:*)",
      "Bash(git commit:*)",
      "Bash(./debugging/scripts/log.sh:*)",
      "Bash(debugging/scripts/log.sh:*)",
      "Read(//Users/<username>/.claude/skills/architect-agent/references/**)",
      "Bash(task test:*)"
    ],
    "deny": [],
    "ask": []
  }
}
```

**Why:** Allows code agent to access protocols, run tests, and use logging scripts without prompts.

### Script-Based Protocols

**Best Practice:** Create bash scripts for repetitive operations (logging, checkpoints) and grant permission once.

**Example:** Logging scripts eliminate 20+ prompts per session:

```bash
# Instead of repeated permission prompts:
echo "[$(date +%H:%M:%S)] Message" >> log.md  # ❌ Prompts every time

# Use approved scripts:
./debugging/scripts/log.sh "Message"          # ✅ No prompts!
./debugging/scripts/log.sh --success "Done"   # ✅ No prompts!
```

**See:** `references/permissions_setup_protocol.md` for complete documentation including:
- Common permission patterns
- Multi-project configurations
- Troubleshooting
- Security considerations

## Directory Structure

```
your-project/
├── instructions/          # Instructions you create for Code Agent
│   └── instruct-*.md
├── human/                 # Your summaries and notes
│   └── human-*.md
├── grades/                # Your evaluations of completed work
│   └── grade-*.md
├── debugging/
│   ├── logs/             # Real-time logs of all work
│   │   └── log-*.md
│   └── scripts/          # Protocol scripts (logging, etc.)
│       ├── log.sh
│       └── start-log.sh
└── current_ticket.md     # Active ticket tracking
```

## Benefits

### For Individual Developers
- **Learn** by observing AI agent decision-making processes
- **Control** exactly what changes are made to your codebase
- **Understand** the rationale behind every code change
- **Document** your development process automatically

### For Teams
- **Audit** AI-generated code changes
- **Share** detailed context about complex changes
- **Train** team members on effective AI collaboration
- **Maintain** consistent quality standards

### For Compliance
- **Track** who (human or AI) made each decision
- **Record** complete audit trails for all changes
- **Prove** due diligence in development process
- **Review** historical decisions and outcomes

## Philosophy

This skill embodies a key principle: **AI agents are powerful assistants, but humans should remain in control.**

By acting as the Architect Agent, you:
- Define the "what" and "why" (instructions)
- Review the "how" and "did it work" (grading)
- Understand the "what happened" (logs)

The AI Code Agent handles the detailed implementation work, but you maintain oversight, learn from the process, and ensure quality standards are met.

## Working with Different AI Tools

This skill works with any AI coding assistant:

- **Claude Code**: Full integration with native slash commands and hooks.json
- **OpenCode**: ✨ Full support via TypeScript plugins or bash wrappers
- **Cursor**: Use instructions as context for AI pair programming
- **GitHub Copilot CLI**: Provide instructions as prompts
- **OpenAI Code Interpreter**: Use structured instructions for code generation
- **Aider**: Feed instructions to guide code modifications

The consistent instruction format ensures your intent is clearly communicated regardless of which tool executes the work.

### OpenCode Support

**NEW:** Full compatibility with OpenCode for code agent workspaces!

**Choose Your Approach:**
- **TypeScript Plugin** - Native OpenCode integration with lifecycle hooks
- **Bash Wrappers** - Works with any OpenCode version

**Key Benefits:**
- ✅ Same 60-70% token reduction as Claude Code hooks
- ✅ Identical log format (grading compatible)
- ✅ Same grading rubrics apply
- ✅ TypeScript or bash - your choice

**Quick Start (Code Agent with OpenCode):**
```bash
# Copy TypeScript plugin (recommended)
cp -r templates/opencode/plugins/logger .opencode/plugins/

# Enable in opencode.json
echo '{"plugins": ["./plugins/logger"]}' > .opencode/opencode.json

# Copy session management scripts
cp templates/opencode/scripts/* debugging/scripts/
chmod +x debugging/scripts/*.sh

# Copy universal logging scripts (same for Claude Code & OpenCode)
cp templates/debugging/scripts/log-decision.sh debugging/scripts/
cp templates/debugging/scripts/get-unstuck.sh debugging/scripts/
```

**See Full Documentation:**
- `references/opencode_logging_protocol.md` - Complete OpenCode protocol
- `references/opencode_setup_guide.md` - Detailed setup instructions
- `references/opencode_migration_guide.md` - Migrate from Claude Code
- `references/claude_vs_opencode_comparison.md` - Feature comparison

## References

See the `references/` directory for detailed protocols:

**Core Protocols:**
- `permissions_setup_protocol.md` - ⭐ Cross-workspace permissions configuration and script-based protocols
- `agent_specialization.md` - When to use which specialized agents
- `testing_protocol.md` - Mandatory testing and quality requirements
- `hybrid_logging_protocol.md` - ✨ NEW: v2.0 logging with hooks (60-70% token savings)
- `file_naming.md` - File naming conventions and patterns
- `git_pr_management.md` - Pull request creation workflows
- `grading_rubrics.md` - Objective evaluation criteria
- `instruction_grading_workflow.md` - ⭐ Iterative instruction-grading workflow protocol

**OpenCode Support:**
- `opencode_logging_protocol.md` - ✨ NEW: Complete OpenCode logging protocol
- `opencode_setup_guide.md` - ✨ NEW: Step-by-step OpenCode setup
- `opencode_migration_guide.md` - ✨ NEW: Migrate from Claude Code to OpenCode
- `claude_vs_opencode_comparison.md` - ✨ NEW: Feature comparison and decision guide

**Templates:**
- `code_agent_claude_template.md` - ⭐ Template for code agent CLAUDE.md sections
- `code_agent_agents_template.md` - ⭐ Template for code agent AGENTS.md collaboration protocol

## Example: Multi-Phase Project

```markdown
# Phase 1: Database Schema
instructions/instruct-2025_10_20-09_00-tkt456_phase1_database_schema.md
grades/grade-2025_10_20-11_30-tkt456_phase1_database_schema.md

# Phase 2: API Endpoints
instructions/instruct-2025_10_20-14_00-tkt456_phase2_api_endpoints.md
grades/grade-2025_10_20-16_45-tkt456_phase2_api_endpoints.md

# Phase 3: Frontend Integration
instructions/instruct-2025_10_21-09_00-tkt456_phase3_frontend_integration.md
grades/grade-2025_10_21-12_15-tkt456_phase3_frontend_integration.md
```

Each phase is tracked, logged, and graded independently, giving you complete visibility into the project's evolution.

## License

This is a user skill for Claude Code. Modify and adapt it to fit your workflow and team needs.

## Contributing

This skill is designed to be customized and improved. When contributing changes:

### Git Workflow Requirements

**CRITICAL: Never commit directly to main branch**

All contributions must follow this workflow:

1. **Create feature/fix branch**
   ```bash
   git checkout -b feat/<description>  # For new features
   git checkout -b fix/<description>   # For bug fixes
   ```

2. **Create GitHub issue FIRST**
   ```bash
   gh issue create \
     --title "Clear description of problem or feature" \
     --body "Detailed description..." \
     --label "bug,documentation"
   ```

3. **Commit with issue reference**
   ```bash
   git commit -m "type: brief description

   Fixes #<issue-number>

   Detailed explanation..."
   ```

4. **Create pull request**
   ```bash
   gh pr create \
     --title "Type: Description" \
     --body "## Fixes #<issue>..." \
     --base main
   ```

### Why This Workflow

- **Review**: Changes reviewed before merging
- **Tracking**: Issues and PRs create audit trail
- **Context**: Full documentation of why/what changed
- **Safety**: Main branch stays stable
- **Collaboration**: Discussion before merge

### What to Contribute

Feel free to:
- Adjust grading rubrics to match your quality standards
- Modify instruction templates for your domain
- Add new protocols for your specific tools and workflows
- Share improvements that help others maintain human-in-the-loop control
- Fix bugs or improve documentation
- Add examples or use cases

All contributions should include:
- Clear problem/enhancement description (in issue)
- Explanation of changes (in PR)
- Testing/verification notes
- Impact assessment
