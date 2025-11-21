<!--
# THIS FILE IS FOR THE ARCHITECT-AGENT SKILL REPOSITORY
This AGENTS.md defines git workflow requirements for THIS repository (the skill itself).
This is NOT a template for user workspaces.

For templates to copy into your workspaces, see:
- templates/architect-workspace/AGENTS.md (for architect agent workspaces)
- templates/code-agent-workspace/AGENTS.md (for code agent workspaces)
-->

# AGENTS.md - Agent Workflow Requirements

## Purpose

This file provides instructions for AI agents (both architect agents and code agents) working with this skill. It defines mandatory workflow requirements that must be followed.

## Git Workflow (MANDATORY)

### CRITICAL: Never Commit Directly to Main

**ALL changes must go through the branch → issue → PR workflow.**

### Required Steps for ALL Changes

#### 1. Create Feature/Fix Branch

```bash
# For new features
git checkout -b feat/<short-description>

# For bug fixes
git checkout -b fix/<short-description>
```

**Examples:**
- `feat/add-testing-protocol`
- `fix/workspace-confusion`
- `feat/improve-grading-rubric`
- `fix/typo-in-logging`

#### 2. Create GitHub Issue FIRST

Before making changes, create an issue describing:

```bash
gh issue create \
  --title "Clear, actionable title" \
  --body "## Problem
[What's wrong or what's needed]

## Root Cause (for bugs)
[Why this issue exists]

## Proposed Solution
[How to fix it]

## Impact
[What this affects]" \
  --label "bug,documentation"  # Choose appropriate labels
```

**Issue should include:**
- Clear problem statement
- Root cause analysis (for bugs)
- Proposed solution
- Expected behavior
- Impact assessment
- Affected components

#### 3. Make Changes and Commit

```bash
git add <files>
git commit -m "type: brief summary

Fixes #<issue-number>

Detailed explanation:
- Change 1
- Change 2
- Why these changes were made
"
```

**Commit message format:**
- **Type prefix**: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`
- **Brief summary**: One line description
- **Issue reference**: `Fixes #<number>` (MANDATORY)
- **Detailed body**: What changed and why

**Example:**
```
fix: clarify file location protocol to prevent workspace confusion

Fixes #2

Added explicit 'CRITICAL: File Location Protocol' section to SKILL.md
to prevent architect agents from writing to code agent workspace.

Changes:
- Added table of contents with warning
- Added visual workspace separation diagram
- Provided wrong vs correct examples
- Added checklist verification item
```

#### 4. Push Branch

```bash
git push -u origin feat/<description>
# OR
git push -u origin fix/<description>
```

#### 5. Create Pull Request

```bash
gh pr create \
  --title "Type: Clear description of change" \
  --body "## Fixes #<issue-number>

## Problem
[Brief description of what was wrong]

## Root Cause
[Why the issue existed]

## Solution
[What was changed to fix it]

### Key Changes
1. Change 1 - Description
2. Change 2 - Description

## Testing
[How the fix was verified]

## Impact
- **Prevents**: [What problems this prevents]
- **Improves**: [What this improves]
- **Affects**: [What components are affected]

## Files Changed
- \`file1.md\`: Description of changes (+X lines)
" \
  --base main
```

**PR must include:**
- Issue reference (`Fixes #<number>`)
- Problem description
- Root cause (for bugs)
- Solution explanation
- List of specific changes
- Testing/verification notes
- Impact assessment
- Files changed summary

### Workflow Summary Diagram

```
1. Create Branch          →  git checkout -b feat/description
2. Create Issue           →  gh issue create (get issue #)
3. Make Changes           →  Edit files
4. Commit with Reference  →  git commit -m "Fixes #X"
5. Push Branch            →  git push -u origin feat/description
6. Create PR              →  gh pr create (references issue #)
7. Review & Merge         →  (after approval)
```

## Why This Workflow is Mandatory

### 1. Review and Quality Control
- Changes are reviewed before merging
- Prevents mistakes from reaching main
- Allows discussion and improvement

### 2. Audit Trail and History
- Issues document why changes were needed
- PRs document what was changed
- Commits link to both
- Full context preserved forever

### 3. Tracking and Project Management
- Issues track work items
- PRs track implementations
- Easy to see what's in progress
- Easy to see what was completed

### 4. Safety and Reversibility
- Easy to revert if needed
- Changes are isolated
- Main branch stays stable
- Less risk of breaking changes

### 5. Collaboration
- Team can see what's happening
- Discussion happens in PR comments
- Multiple reviewers can provide input
- Knowledge sharing through documentation

## Protection Rules

### Main Branch Protection (Recommended)

```yaml
Branch Protection Rules for 'main':
- Require pull request before merging
- Require approvals: 1
- Require status checks to pass
- Require branches to be up to date
- Do not allow bypassing
```

### Enforcement

**Agents MUST:**
- ❌ NEVER commit directly to main
- ✅ ALWAYS create branch first
- ✅ ALWAYS create issue before changes
- ✅ ALWAYS reference issue in commit
- ✅ ALWAYS create PR with description
- ✅ ALWAYS wait for review before merge

**If agent attempts direct commit to main:**
- Stop the commit
- Create branch instead
- Follow proper workflow

## Examples

### Example 1: Bug Fix Workflow

```bash
# 1. Create branch
git checkout -b fix/workspace-location-confusion

# 2. Create issue
gh issue create \
  --title "Architect agents writing to code agent workspace" \
  --body "..." \
  --label "bug,documentation"
# Returns: Issue #2

# 3. Make changes
# Edit SKILL.md

# 4. Commit
git add SKILL.md
git commit -m "fix: clarify file location protocol

Fixes #2

Added explicit workspace separation section..."

# 5. Push
git push -u origin fix/workspace-location-confusion

# 6. Create PR
gh pr create \
  --title "Fix: Add explicit file location protocol" \
  --body "## Fixes #2
..." \
  --base main
# Returns: PR #3
```

### Example 2: Feature Addition Workflow

```bash
# 1. Create branch
git checkout -b feat/add-error-recovery-protocol

# 2. Create issue
gh issue create \
  --title "Add error recovery protocol to references" \
  --body "..." \
  --label "enhancement,documentation"
# Returns: Issue #4

# 3. Make changes
# Create references/error_recovery.md

# 4. Commit
git add references/error_recovery.md
git commit -m "feat: add error recovery protocol

Fixes #4

Added comprehensive error recovery protocol document..."

# 5. Push
git push -u origin feat/add-error-recovery-protocol

# 6. Create PR
gh pr create \
  --title "Feat: Add error recovery protocol reference" \
  --body "## Fixes #4
..." \
  --base main
# Returns: PR #5
```

## Quick Reference

**Branch naming:**
- Features: `feat/<description>`
- Fixes: `fix/<description>`

**Always include in commits:**
- `Fixes #<number>`

**Always include in PRs:**
- `## Fixes #<number>`
- Problem description
- Solution description
- Testing notes
- Impact assessment

**Never:**
- ❌ Commit directly to main
- ❌ Skip issue creation
- ❌ Skip issue reference in commit
- ❌ Skip PR description

## Grading Impact (for Code Agents)

Following this workflow affects grading:

**Proper workflow (+5 points):**
- Created issue before work
- Created branch properly
- Committed with issue reference
- Created PR with full description

**Improper workflow (deductions):**
- No issue created: -2 points
- Direct commit to main: -5 points
- No issue reference in commit: -2 points
- Incomplete PR description: -2 points

## Related Documentation

- `CLAUDE.md` - Git workflow requirements (this document's companion)
- `SKILL.md` - Main architect agent skill documentation
- `references/git_pr_management.md` - Git and PR management details
