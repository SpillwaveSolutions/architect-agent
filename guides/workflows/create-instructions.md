# Workflow: Create Instructions

**Trigger:** User says "write instructions for code agent" or "create instructions"

## Prerequisites

Before creating instructions, verify:

```bash
# Check architect workspace structure exists
ls -la instructions/ human/ grades/ ticket/
```

If missing, inform user to initialize workspace first.

## Workflow Steps

### 1. Gather Context

- Review `ticket/current_ticket.md` for ticket details
- Check `analysis/` for any prior research
- Ask clarifying questions if requirements unclear

### 2. Generate Timestamp

```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
# Example: 20251127_143045
```

### 3. Create Technical Instructions

**File:** `instructions/instruct-${TIMESTAMP}-description.md`

**Structure:**
```markdown
# INSTRUCT: [Clear Title]

**Date:** YYYY-MM-DD
**Ticket:** [TICKET-ID] (if applicable)
**Phase:** [Phase number if multi-phase]

## Context
[Background information code agent needs]

## Objectives
- Primary objective
- Secondary objectives

## Requirements
- Specific technical requirements
- Quality standards to meet

## Constraints
- What NOT to do
- Known limitations
- Gotchas to avoid

## Implementation Steps
1. First step with details
2. Second step with details
3. Continue as needed

## Success Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] All tests pass

## Testing Requirements
- Required test types
- Minimum coverage expectations
- Specific test scenarios

## References
- Links to relevant documentation
- Related analysis files
```

### 4. Create Human Summary

**File:** `human/human-${TIMESTAMP}-description.md`

**Format:** 10-25 bullet points covering:

```markdown
# Human Summary: [Title]

## Main Objectives (2-4 bullets)
- Primary goal
- Key deliverable

## Key Requirements (3-6 bullets)
- Technical requirement 1
- Technical requirement 2

## Critical Constraints (2-4 bullets)
- Must avoid X
- Cannot change Y

## Success Criteria (2-4 bullets)
- All tests pass
- Coverage >= X%

## Testing Requirements (2-4 bullets)
- Unit tests for new code
- Integration tests if applicable
```

### 5. Verify Files Match

```bash
# Both files should have same timestamp
ls -la instructions/instruct-${TIMESTAMP}-*.md
ls -la human/human-${TIMESTAMP}-*.md
```

### 6. Display Human Summary

After creating both files, display the human summary to user for review before sending.

## Quick Checklist

- [ ] Ticket context reviewed
- [ ] Technical instructions created in `instructions/`
- [ ] Human summary created in `human/`
- [ ] Timestamps match between files
- [ ] Success criteria are measurable
- [ ] Testing requirements specified

## Next Action

After user approves:
- Run "send instructions to code agent"
- Or use `/project.send` command