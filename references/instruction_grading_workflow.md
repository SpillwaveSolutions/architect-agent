# Instruction-Grading Workflow Protocol

## Overview

This protocol enables architect agents to send instructions to code agents, track their execution, grade the work, and iteratively improve until achieving ≥95% quality scores. The workflow uses the code agent's `debugging/instructions/` directory as a temporary workspace while maintaining all history in the architect agent's directories.

## Directory Separation

### Architect Agent Workspace (YOU work here)
```
/path/to/architect/workspace/
├── instructions/         # Original instructions + archive
├── grades/              # All grade history
├── human/               # Human summaries + archive
├── ticket/              # Ticket tracking
└── CLAUDE.md            # References code agent location
```

### Code Agent Workspace (THEY work there)
```
/path/to/code/agent/workspace/
├── src/                 # Their codebase
├── debugging/
│   ├── logs/           # Execution logs they create
│   └── instructions/   # TEMPORARY workspace for active instructions
├── CLAUDE.md           # Includes instruction protocol
└── AGENTS.md           # Includes delegation protocol
```

## File Naming Convention

### Architect Agent Directories
Standard naming (existing convention):
```
instructions/instruct-YYYY_MM_DD-HH_MM-ticket_id_phase_description.md
grades/grade-YYYY_MM_DD-HH_MM-ticket_id_phase_description.md
human/human-YYYY_MM_DD-HH_MM-ticket_id_phase_description.md
```

### Code Agent Temporary Instructions
```
debugging/instructions/<6-digit-uuid>-YYYYMMDD-HHMM.md                    # Active instruction
debugging/instructions/<6-digit-uuid>-YYYYMMDD-HHMM-graded-<score>.md   # Graded, awaiting cleanup
```

**UUID Generation**: Use random 6-character hex (e.g., `a1b2c3`, `d4e5f6`)

## Complete Workflow

### Phase 1: Send Instructions to Code Agent

**You tell architect agent:** "send instructions to code agent"

**Architect agent actions:**
1. Create standard instruction file in architect workspace:
   ```
   instructions/instruct-2025_10_30-14_30-tkt123_phase2_implement_auth.md
   ```

2. Generate 6-digit UUID (e.g., `a1b2c3`)

3. Copy instruction to code agent workspace with simplified naming:
   ```
   /path/to/code-agent/debugging/instructions/a1b2c3-20251030-1430.md
   ```

4. Generate 10-point summary (adapt based on complexity):
   - Simple task: 3-5 bullet points
   - Medium task: 7-10 bullet points
   - Complex task: 10-15 bullet points with categorization

5. Display to user:
   ```
   📄 File: debugging/instructions/a1b2c3-20251030-1430.md

   📋 Summary (10 points):
   1. Implement JWT-based authentication
   2. Create user login endpoint
   3. Add password hashing with bcrypt
   4. Implement token refresh mechanism
   5. Add middleware for protected routes
   6. Write unit tests for auth logic
   7. Write integration tests for endpoints
   8. Update API documentation
   9. Add rate limiting to login endpoint
   10. Ensure 80%+ code coverage

   ✅ Instructions ready. Tell code agent to "run instructions"
   ```

### Phase 2: Code Agent Execution

**You tell code agent:** "run instructions"

**Code agent actions:**
1. Check `debugging/instructions/` directory
2. If single file exists: Auto-run
3. If multiple files exist: Prompt user to select
4. Execute tasks per instruction file
5. Create logs in `debugging/logs/`
6. Signal completion: "Instructions completed, ready for grading"

**Code agent multi-file detection:**
```
Found 3 instruction sets:
1. [a1b2c3] Feature: User Authentication (2025-10-30 14:30)
2. [d4e5f6] Fix: Memory Leak (2025-10-30 16:45) [NEEDS IMPROVEMENT - Score: 82%]
3. [g7h8i9] Refactor: Database Layer (2025-10-30 18:20)

Which would you like to run? (1-3, or 'latest')
```

### Phase 3: Grading

**You tell architect agent:** "grade the work"

**Architect agent actions:**

#### Step 1: Cleanup Previous Graded Files
```bash
# Delete any files matching *-graded-*.md pattern
rm -f /path/to/code-agent/debugging/instructions/*-graded-*.md
```

#### Step 2: Grade Current Work
1. Read code agent's logs from `debugging/logs/`
2. Review code changes
3. Apply grading rubric (see `grading_rubrics.md`)
4. Calculate score (0-100)

#### Step 3: Handle Based on Score

**If score ≥95% (SUCCESS):**
```
1. Display grade report
2. Delete instruction file from code agent workspace
3. Archive in architect workspace (already exists)
4. Optionally update code agent's CLAUDE.md with learnings

Output:
✅ Grade: 97%

Excellent work! All criteria met:
- Completeness: 25/25
- Code Quality: 20/20
- Testing: 19/20
- Documentation: 15/15
- Resilience: 10/10
- Logging: 8/10

Instruction file deleted from code agent workspace.

Added to code agent's CLAUDE.md:
## Authentication Patterns
- JWT implementation with refresh tokens (scored 97%)
- Pattern: Separate auth logic from HTTP handlers
- Reuse for future auth features
```

**If score <95% (NEEDS IMPROVEMENT):**
```
1. Rename current instruction with grade:
   a1b2c3-20251030-1430.md → a1b2c3-20251030-1430-graded-82.md

2. Generate new UUID (e.g., d4e5f6)

3. Create improvement instruction:
   debugging/instructions/d4e5f6-20251030-1645.md

4. Link to original instruction in improvement file

5. Display detailed feedback

Output:
📊 Grade: 82%

❌ Missing (18 points):
- Rate limiting not implemented (-10)
- Integration tests incomplete (-5)
- Documentation missing examples (-3)

📝 Created improvement instructions: debugging/instructions/d4e5f6-20251030-1645.md

Summary:
1. Add express-rate-limit to login endpoint
2. Complete integration test suite
3. Add curl examples to API docs

Tell code agent: "improve your score"

Files in code agent workspace:
- a1b2c3-20251030-1430-graded-82.md (reference)
- d4e5f6-20251030-1645.md (work on this)
```

6. Update code agent's CLAUDE.md with pattern to avoid:
```markdown
## Testing Requirements
- Integration tests must cover happy path + error cases
- You missed error case testing in auth implementation
- Always include: invalid credentials, expired tokens, missing headers
```

### Phase 4: Improvement Iteration

**You tell code agent:** "improve your score"

**Code agent actions:**
1. Detect improvement instruction (`d4e5f6-20251030-1645.md`)
2. Read improvement guidance
3. Reference original graded file for context (`a1b2c3-...-graded-82.md`)
4. Implement fixes
5. Signal: "Improvements completed, ready for re-grading"

**You tell architect agent:** "grade the work"

**Architect agent re-grading:**
1. **Delete old graded file** (`a1b2c3-...-graded-82.md`)
2. Grade new work (`d4e5f6`)
3. If ≥95%: Delete `d4e5f6`, done
4. If <95%: Rename to `d4e5f6-...-graded-89.md`, create new improvement

## Improvement Instruction Structure

When creating improvement instructions, include:

```markdown
# Instructions: d4e5f6
Original: a1b2c3
Attempt: 2
Previous Score: 82%

## What Was Missing

Based on grading of previous attempt:
- Rate limiting not implemented (lost 10 points)
- Integration tests incomplete (lost 5 points)
- Documentation missing examples (lost 3 points)

## Target Improvement Areas

### 1. Add Rate Limiting (Priority: High)
**What to do:**
- Install express-rate-limit package
- Add to login endpoint: max 5 attempts per 15 minutes
- Test with multiple rapid requests

**Success criteria:**
- Rate limiter blocks after 5 attempts
- Returns 429 status code
- Includes Retry-After header

### 2. Complete Integration Tests (Priority: High)
**What to do:**
- Add error case tests:
  - Invalid credentials
  - Expired tokens
  - Missing authorization headers
- Ensure all endpoints covered

**Success criteria:**
- Test coverage ≥80% for auth module
- All error cases tested
- Tests pass consistently

### 3. Add Documentation Examples (Priority: Medium)
**What to do:**
- Add curl examples to API docs
- Show successful login
- Show error responses

**Success criteria:**
- Examples work when copy-pasted
- Cover both success and error cases

## Original Context

Reference the original instruction for full requirements:
`debugging/instructions/a1b2c3-20251030-1430-graded-82.md`

You already completed:
✅ JWT authentication implementation
✅ Password hashing with bcrypt
✅ Token refresh mechanism
✅ Protected route middleware
✅ Basic unit tests

Only work on the improvement areas above.
```

## File Lifecycle Examples

### Success on First Try
```
State 1: Fresh instruction
debugging/instructions/a1b2c3-20251030-1430.md

↓ Code agent executes

State 2: Grading (97% - success!)
Architect deletes: a1b2c3-20251030-1430.md

State 3: Clean
debugging/instructions/ (empty)
```

### Two Iteration Cycle
```
State 1: Fresh instruction
debugging/instructions/a1b2c3-20251030-1430.md

↓ Grade: 82%

State 2: After first grading
debugging/instructions/
├── a1b2c3-20251030-1430-graded-82.md (reference)
└── d4e5f6-20251030-1645.md (work on this)

↓ Code agent improves
↓ Grade: 96%

State 3: After second grading (cleanup happens)
Architect deletes:
- a1b2c3-...-graded-82.md (old graded file)
- d4e5f6-20251030-1645.md (current file - success!)

State 4: Clean
debugging/instructions/ (empty)
```

### Three Iteration Cycle
```
State 1: Fresh instruction
debugging/instructions/a1b2c3-20251030-1430.md

↓ Grade: 82%

State 2: After first grading
debugging/instructions/
├── a1b2c3-...-graded-82.md
└── d4e5f6-....md (improvement 1)

↓ Grade: 89% (still <95%)

State 3: After second grading
Architect deletes: a1b2c3-...-graded-82.md
debugging/instructions/
├── d4e5f6-...-graded-89.md (kept as reference)
└── g7h8i9-....md (improvement 2)

↓ Grade: 97% (success!)

State 4: After third grading (cleanup)
Architect deletes:
- d4e5f6-...-graded-89.md
- g7h8i9-....md

State 5: Clean
debugging/instructions/ (empty)
```

## Memory Updates to Code Agent

### CLAUDE.md Updates

Architect updates code agent's CLAUDE.md to embed learnings:

**When to update:**
- Pattern failure (score <95% on same task type 2+ times)
- Significant success (score ≥98%)
- Explicit learning identified

**Example additions:**

```markdown
## Architect-Delegated Instructions Protocol

### How to Receive Instructions
1. Architect creates: `debugging/instructions/<uuid>-YYYYMMDD-HHMM.md`
2. You receive notification with filename + summary
3. Commands:
   - "run instructions" - auto-runs if single file exists
   - "run instruction <uuid>" - runs specific instruction

### How Instructions are Graded
- Target score: 95%
- Architect evaluates against rubric in instruction file
- Score ≥95%: Instruction deleted (success)
- Score <95%: New improvement instruction created

### Post-Grading Actions
- "improve your score" - read latest instruction for improvement guidance
- Architect updates this section with learnings

---

## Learnings from Architect (Auto-Updated)

### Error Handling Patterns
<!-- Added by architect after repeated failures -->
- Always wrap database operations in try-catch with specific error types
- Log errors with context: `logger.error({operation, params, error})`
- Return structured error responses: `{success: false, error: {code, message}}`

### Testing Requirements
<!-- Added after grading feedback on auth feature (score: 82% → 96%) -->
- Minimum 80% code coverage for new features
- Include edge cases: null, undefined, empty arrays
- Integration tests must cover happy path + error cases
- You missed error case testing in auth implementation
- Always include: invalid credentials, expired tokens, missing headers

### Code Organization
<!-- Added after successful high-scoring implementations -->
- Separate business logic from HTTP handlers (score: 97% on auth feature)
- Use dependency injection for testability
- Keep functions under 50 lines

### Project-Specific Conventions
<!-- Added based on this codebase's patterns -->
- Use async/await, not callbacks
- Configuration via environment variables, validated at startup
- API responses follow `{data, error, metadata}` structure
```

### AGENTS.md Updates

Architect updates code agent's AGENTS.md to document collaboration patterns:

```markdown
## Architect Agent Delegation Protocol

### Receiving Work Instructions
When architect agent delegates work to you (code agent):

1. **Instruction Location**: `debugging/instructions/<uuid>-YYYYMMDD-HHMM.md`

2. **Instruction Format**:
   ```markdown
   # Instructions: <UUID>

   ## Objective
   [Clear goal]

   ## Success Criteria (Grading Rubric)
   - [ ] Criterion 1 (20 points)
   - [ ] Criterion 2 (30 points)

   ## Tasks
   1. Specific task with acceptance criteria
   2. ...
   ```

3. **Your Response**:
   - Acknowledge receipt
   - Confirm understanding
   - Execute tasks
   - Signal completion: "instructions completed, ready for grading"

4. **Grading Cycle**:
   - Architect evaluates your work
   - Score ≥95%: Success, instruction deleted
   - Score <95%: Improvement instruction created
   - You respond to: "improve your score"

---

## Architect-Provided Patterns (Auto-Updated)

### When You Struggled Before
<!-- Architect adds these after <95% scores -->

**Database Migrations (Failed 2x, then succeeded)**:
- ❌ Don't modify existing migrations
- ✅ Create new migration file
- ✅ Test rollback before committing

**API Design (Score: 88% → 97%)**:
- Improvement: Added request validation schemas
- Learning: Define schemas before implementing handlers

### When You Excelled
<!-- Architect adds these after ≥95% scores -->

**Authentication Feature (Score: 98%)**:
- Pattern: JWT + refresh token architecture
- Testing: Mocked time-based token expiry
- Reuse this pattern for authorization features

**Performance Optimization (Score: 96%)**:
- Approach: Profiled first, optimized hot paths only
- Tools: Used benchmark suite before/after
- Apply to future optimization tasks
```

## Grading Cleanup Protocol

### When Architect Grades

**Step 1: Delete old graded files**
```bash
# Remove all previously graded files
find /path/to/code-agent/debugging/instructions/ \
  -name "*-graded-*.md" \
  -delete
```

**Step 2: Grade current work**
- Apply rubric
- Calculate score

**Step 3: Take action based on score**

If score ≥95%:
```bash
# Delete current instruction (success!)
rm /path/to/code-agent/debugging/instructions/<uuid>-YYYYMMDD-HHMM.md
```

If score <95%:
```bash
# Rename with grade
mv /path/to/code-agent/debugging/instructions/<uuid>-YYYYMMDD-HHMM.md \
   /path/to/code-agent/debugging/instructions/<uuid>-YYYYMMDD-HHMM-graded-<score>.md

# Create new improvement instruction
# (with new UUID and timestamp)
```

### Maximum Files in Directory

**Typical state:** 0-2 files
- 0 files: No active work
- 1 file: Current instruction to work on
- 2 files: Previous graded file + new improvement instruction

**After cleanup:** 0 files (all work completed successfully)

## Code Agent Commands

### Running Instructions

**Single instruction present:**
```
You: "run instructions"
Code Agent: Automatically runs the single instruction file
```

**Multiple instructions present:**
```
You: "run instructions"
Code Agent: Lists available instructions with context, asks which to run

You: "run instruction a1b2c3"
Code Agent: Runs specific instruction by UUID
```

### Improving Score

**After receiving <95% grade:**
```
You: "improve your score"
Code Agent:
1. Finds latest improvement instruction
2. References previous graded file for context
3. Implements targeted improvements
4. Signals completion
```

## Architect Agent Implementation Notes

### UUID Generation
```python
import random
import string

def generate_uuid():
    """Generate 6-character hex UUID"""
    return ''.join(random.choices('0123456789abcdef', k=6))
```

### Summary Generation
```python
def generate_summary(instruction_content, complexity):
    """
    Generate adaptive summary based on complexity

    Args:
        instruction_content: Full instruction text
        complexity: "simple" | "medium" | "complex"

    Returns:
        List of summary points (3-15 items)
    """
    if complexity == "simple":
        return extract_key_points(instruction_content, max_points=5)
    elif complexity == "medium":
        return extract_key_points(instruction_content, max_points=10)
    else:  # complex
        return extract_categorized_points(instruction_content, max_points=15)
```

### Grading Flow
```python
def grade_work(instruction_uuid):
    # Step 1: Cleanup
    delete_old_graded_files()

    # Step 2: Grade
    score = evaluate_against_rubric()

    # Step 3: Handle result
    if score >= 95:
        delete_instruction(instruction_uuid)
        update_code_agent_memory_if_needed()
        return success_report(score)
    else:
        rename_with_grade(instruction_uuid, score)
        improvement_uuid = generate_uuid()
        create_improvement_instruction(improvement_uuid, score, gaps)
        update_code_agent_memory_with_patterns()
        return improvement_report(score, improvement_uuid)
```

## Integration with Existing Architect Agent Workflow

### Preserving Existing Protocols

This instruction-grading workflow **supplements** the existing architect agent workflow. All existing protocols remain in effect:

- **Logging Protocol** (`logging_protocol.md`): Still required
- **Testing Protocol** (`testing_protocol.md`): Still required
- **Grading Rubrics** (`grading_rubrics.md`): Same scoring system
- **File Naming** (`file_naming.md`): Architect workspace uses existing convention
- **All other references**: Unchanged

### Dual File Creation

When sending instructions to code agent:

1. **Create standard instruction** in architect workspace:
   ```
   instructions/instruct-2025_10_30-14_30-tkt123_phase2_implement_auth.md
   ```
   - Full detail
   - Follows existing instruction_structure.md template
   - Archived normally in architect workspace

2. **Copy to code agent workspace** with simplified naming:
   ```
   debugging/instructions/a1b2c3-20251030-1430.md
   ```
   - Same content
   - Simplified naming for code agent convenience
   - Temporary (deleted after grading)

### Grade Storage

Grades always stored in architect workspace:
```
grades/grade-2025_10_30-16_45-tkt123_phase2_implement_auth.md
```

No grades stored in code agent workspace.

## Summary

This workflow provides:
1. **Clear instruction delivery** to code agents via temporary workspace
2. **Iterative improvement** until quality threshold (95%) achieved
3. **Automatic cleanup** of temporary files (Option 3: on next grading cycle)
4. **Memory retention** by updating code agent's CLAUDE.md and AGENTS.md
5. **Full compatibility** with existing architect agent protocols
6. **Separation of concerns** between architect planning and code execution
