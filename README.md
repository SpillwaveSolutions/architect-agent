# Architect Agent Skill

Transform Claude Code (or any AI coding assistant) into a specialized **architect agent** that plans, delegates work to code agents, grades implementations, and maintains quality through iterative improvement.

---

## What This Skill Does

**Plan -> Delegate -> Grade -> Iterate -> Learn**

1. **Plan**: Create detailed, structured instructions for code agents
2. **Delegate**: Send instructions to code agents for implementation
3. **Grade**: Evaluate completed work against objective rubrics (target: 95% or higher)
4. **Iterate**: Guide improvements until quality threshold met
5. **Learn**: Update code agent memory with successful patterns

---

## Installation

### Skilz Universal Installer (Recommended)

Install instantly using the [skilz CLI](https://github.com/AgenDev-FX/skilz):

```bash
skilz install SpillwaveSolutions_architect-agent/architect-agent
```

**Marketplace:** [SpillwaveSolutions_architect-agent/architect-agent](https://skillzwave.ai/skill/SpillwaveSolutions__architect-agent__architect-agent__SKILL/)

### Manual Installation

Clone directly into your Claude Code skills directory:

```bash
git clone https://github.com/SpillwaveSolutions/architect-agent.git ~/.claude/skills/architect-agent
```

---

## Key Features

- **Objective Grading** - 6-category rubric (100 points total)
- **Iterative Improvement** - Repeat until 95% or higher quality achieved
- **Memory Management** - Code agents learn from successes and failures
- **Progressive Disclosure** - 3-level architecture minimizes context usage
- **Cross-Workspace Collaboration** - Architect to code agent workflows
- **Template Automation** - Setup workspaces in less than 5 minutes
- **Dual-Mode Logging** - Works with Claude Code and OpenCode
- **Comprehensive Protocols** - 29 reference files covering all scenarios

---

## Quick Start

### Option 1: Automated Setup (Recommended)

```bash
# Navigate to templates
cd ~/.claude/skills/architect-agent/templates/

# Create code agent workspace
./setup-workspace.sh code-agent ~/projects/my-code-agent

# Create architect workspace (optional)
./setup-workspace.sh architect ~/projects/my-architect \
    --code-agent-path ~/projects/my-code-agent

# Verify installation
cd ~/projects/my-code-agent
~/projects/my-architect/verify-workspace.sh
```

**Complete in less than 5 minutes!** See [references/installation.md](references/installation.md) for details.

### Option 2: Manual Setup

Use skill triggers for step-by-step guidance:
- "This is a new architect agent, help me set it up"
- "Write instructions for code agent"
- "Grade the code agent's work"

---

## Core Workflows

### 1. Instruction Creation

```
User: "write instructions for implementing JWT authentication"

Architect Agent:
  -> Creates human-readable summary (human/*.md)
  -> Creates detailed technical instructions (instructions/*.md)
  -> Includes logging requirements, testing protocol, success criteria
```

### 2. Delegation and Execution

```
Architect: "send instructions to code agent"
  -> Copies to code-agent/debugging/instructions/<uuid>.md
  -> Generates 10-point summary

Code Agent: "run instructions"
  -> Implements features
  -> Creates detailed logs
  -> Signals: "instructions completed, ready for grading"
```

### 3. Grading and Iteration

```
Architect: "grade the work"
  -> Evaluates against rubric
  -> If 95% or higher: Success! Files deleted
  -> If less than 95%: Creates improvement instruction

Code Agent: "improve your score" (if needed)
  -> Implements targeted fixes
  -> Repeat until 95% or higher
```

---

## Architecture

### Three-Level Progressive Disclosure

**Level 1: Metadata** (~100 words)
- Always in context
- Skill name, description, triggers

**Level 2: SKILL.md** (less than 5k words)
- Core workflows and protocols
- Quick reference checklists
- Links to detailed references

**Level 3: References** (unlimited)
- 29 detailed protocol files
- Loaded only when needed
- Keeps context window lean

### Multi-Workspace Structure

```
Architect Workspace           Code Agent Workspace
(YOU work here)                (THEY work there)
===================           ====================
instructions/                 src/
  instruct-*.md <- YOU          code files <- THEY
human/                        tests/
  human-*.md <- YOU             test files <- THEY
grades/                       debugging/
  grade-*.md <- YOU               logs/ <- THEY
ticket/                          instructions/ (temporary)
analysis/                     CLAUDE.md (memory)
CLAUDE.md                     AGENTS.md (protocols)
```

---

## Documentation

### Essential Reading

1. **[SPEC.md](SPEC.md)** - Project specification (purpose, scope, architecture)
2. **[SKILL.md](SKILL.md)** - Main skill documentation (all triggers and workflows)
3. **[references/README.md](references/README.md)** - Index of all 29 reference files
4. **[CONTRIBUTING.md](CONTRIBUTING.md)** - Git workflow and contribution guidelines

### Quick Links

**Setup and Installation:**
- [references/installation.md](references/installation.md) - Complete installation guide
- [references/upgrade.md](references/upgrade.md) - Migration from v1.0/v2.0 to v3.0+
- [references/quick_start.md](references/quick_start.md) - 5-minute getting started

**Core Protocols:**
- [references/logging_protocol.md](references/logging_protocol.md) - Real-time logging with tee
- [references/testing_protocol.md](references/testing_protocol.md) - Progressive testing schedule
- [references/grading_rubrics.md](references/grading_rubrics.md) - 6-category grading system
- [references/agent_specialization.md](references/agent_specialization.md) - Right agent for the job

**Advanced:**
- [references/instruction_grading_workflow.md](references/instruction_grading_workflow.md) - Iterative improvement cycle
- [references/permissions_setup_protocol.md](references/permissions_setup_protocol.md) - Cross-workspace permissions

**OpenCode Integration:**
- [references/opencode_integration_quickstart.md](references/opencode_integration_quickstart.md) - Dual-mode setup
- [references/claude_vs_opencode_comparison.md](references/claude_vs_opencode_comparison.md) - Feature comparison

---

## Grading Rubric

| Category | Points | Key Criteria |
|----------|--------|--------------|
| Completeness | 25 | All requirements met, success criteria checked |
| Code Quality | 20 | Best practices, maintainability, correctness |
| Testing and Verification | 20 | Coverage 60% or higher, all actions verified |
| Documentation | 15 | Complete logs, change docs, inline comments |
| Resilience and Adaptability | 10 | Recovery from errors, smart workarounds |
| Logging and Traceability | 10 | Real-time logs, timestamps, clear decisions |

**Target: 95 points or higher for successful completion**

**Automatic Grade Caps:**
- No unit tests run: Max D (65%)
- Tests fail: F (50%) - UNACCEPTABLE
- Coverage less than 60%: Max C- (70%)

---

## Version History

- **v4.0 (Current)**: Comprehensive reorganization, all references linked, seamless UX
- **v3.0**: Hooks fix (settings.json), automated templates, verification scripts
- **v2.0**: Hybrid logging, improved protocols
- **v1.0**: Initial release (manual logging)

---

## Contributing

**See [CONTRIBUTING.md](CONTRIBUTING.md) for complete workflow.**

**Quick Summary:**
1. Create feature/fix branch (`feat/<description>` or `fix/<description>`)
2. Create GitHub issue FIRST
3. Commit with issue reference (`Fixes #<number>`)
4. Create pull request with full description
5. Never commit directly to main

---

## Support and Community

**Documentation:**
- Browse [references/](references/) for detailed protocols
- Read [SPEC.md](SPEC.md) for project architecture
- Check [SKILL.md](SKILL.md) for complete usage guide

**Getting Help:**
- Review [references/get_unstuck_protocol.md](references/get_unstuck_protocol.md) for troubleshooting
- Check [references/quick_start.md](references/quick_start.md) for common questions
- Create an issue for bugs or feature requests

---

## License

MIT License - Modify and adapt for your workflow and team needs.

---

**Last Updated:** 2025-12-29
**Version:** 4.0
