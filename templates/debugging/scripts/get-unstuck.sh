#!/bin/bash
# Get Unstuck Protocol Orchestration Script
# Automates multi-channel research when code agent is blocked
# Usage: ./debugging/scripts/get-unstuck.sh --error "error msg" --context "what doing" --attempts 3

set -e

# Parse arguments
ERROR_MSG=""
CONTEXT=""
ATTEMPTS=0
PROBLEM_TYPE=""
USE_GEMINI=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --error)
            ERROR_MSG="$2"
            shift 2
            ;;
        --context)
            CONTEXT="$2"
            shift 2
            ;;
        --attempts)
            ATTEMPTS="$2"
            shift 2
            ;;
        --type)
            PROBLEM_TYPE="$2"
            shift 2
            ;;
        --use-gemini)
            USE_GEMINI=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate inputs
if [ -z "$ERROR_MSG" ] || [ -z "$CONTEXT" ] || [ "$ATTEMPTS" -lt 2 ]; then
    echo "Usage: $0 --error \"error message\" --context \"what you're doing\" --attempts N"
    echo "  --type [api|error|concept|unknown]  (optional, auto-detects if not provided)"
    echo "  --use-gemini                        (optional, consult gemini skill if available)"
    echo ""
    echo "Example:"
    echo "  $0 --error \"401 Unauthorized\" --context \"OAuth API auth\" --attempts 3 --type api"
    exit 1
fi

# Get current log file
CURRENT_LOG=$(cat debugging/current_log_file.txt 2>/dev/null)
if [ -z "$CURRENT_LOG" ]; then
    echo "Error: No active log session. Run /log-start first."
    exit 1
fi

LOG_FILE="$CURRENT_LOG"

# Auto-detect problem type if not specified
if [ -z "$PROBLEM_TYPE" ]; then
    if echo "$ERROR_MSG $CONTEXT" | grep -qi "api\|endpoint\|request\|response\|auth"; then
        PROBLEM_TYPE="api"
    elif echo "$ERROR_MSG" | grep -q "Error:\|Exception:\|Failed:"; then
        PROBLEM_TYPE="error"
    elif echo "$CONTEXT" | grep -qi "how to\|implement\|understand"; then
        PROBLEM_TYPE="concept"
    else
        PROBLEM_TYPE="unknown"
    fi
fi

# Log start of Get Unstuck protocol
echo "[$(date +%H:%M:%S)] 🔍 GET UNSTUCK PROTOCOL ACTIVATED" >> "$LOG_FILE"
echo "**Attempts:** $ATTEMPTS" >> "$LOG_FILE"
echo "**Error:** $ERROR_MSG" >> "$LOG_FILE"
echo "**Context:** $CONTEXT" >> "$LOG_FILE"
echo "**Problem Type:** $PROBLEM_TYPE" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"

# Check MCP availability (simple detection)
HAS_PERPLEXITY=false
HAS_BRAVE=false
HAS_CONTEXT7=false

# Detection: Try to list available MCP tools (Claude will know)
# For this script, we assume they're available and let Claude handle fallbacks
HAS_PERPLEXITY=true
HAS_BRAVE=true
HAS_CONTEXT7=true

echo "[$(date +%H:%M:%S)] 📡 Research channels available:" >> "$LOG_FILE"
echo "- Perplexity MCP: ${HAS_PERPLEXITY}" >> "$LOG_FILE"
echo "- Brave MCP: ${HAS_BRAVE}" >> "$LOG_FILE"
echo "- Context7 MCP: ${HAS_CONTEXT7}" >> "$LOG_FILE"
echo "- WebSearch: always available" >> "$LOG_FILE"
echo "- Gemini skill: ${USE_GEMINI}" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Create research summary file
RESEARCH_FILE="debugging/get-unstuck-$(date +%Y%m%d-%H%M%S).md"

cat > "$RESEARCH_FILE" <<EOF
# Get Unstuck Research

**Error:** $ERROR_MSG
**Context:** $CONTEXT
**Attempts:** $ATTEMPTS
**Problem Type:** $PROBLEM_TYPE
**Timestamp:** $(date +%Y-%m-%d\ %H:%M:%S)

---

## Research Channels

EOF

echo "[$(date +%H:%M:%S)] 📝 Research summary will be saved to: $RESEARCH_FILE" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Generate search queries based on problem type
case "$PROBLEM_TYPE" in
    api)
        QUERY_1="$ERROR_MSG API documentation"
        QUERY_2="$ERROR_MSG authentication fix"
        QUERY_3="how to fix $ERROR_MSG"
        CONTEXT7_TOPIC="authentication"
        ;;
    error)
        QUERY_1="\"$ERROR_MSG\" solution"
        QUERY_2="$ERROR_MSG fix"
        QUERY_3="$ERROR_MSG troubleshooting"
        CONTEXT7_TOPIC="error handling"
        ;;
    concept)
        QUERY_1="$CONTEXT best practices"
        QUERY_2="how to $CONTEXT"
        QUERY_3="$CONTEXT tutorial"
        CONTEXT7_TOPIC="getting started"
        ;;
    *)
        QUERY_1="$ERROR_MSG $CONTEXT"
        QUERY_2="$ERROR_MSG solution"
        QUERY_3="$CONTEXT troubleshooting"
        CONTEXT7_TOPIC="general"
        ;;
esac

echo "[$(date +%H:%M:%S)] 🎯 Recommended search queries:" >> "$LOG_FILE"
echo "1. $QUERY_1" >> "$LOG_FILE"
echo "2. $QUERY_2" >> "$LOG_FILE"
echo "3. $QUERY_3" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Add to research summary
cat >> "$RESEARCH_FILE" <<EOF
### Recommended Queries

1. **Query 1:** $QUERY_1
2. **Query 2:** $QUERY_2
3. **Query 3:** $QUERY_3

---

## Instructions

**You should now manually execute these searches using:**

### 1. Perplexity MCP (AI-Powered Search)
\`\`\`typescript
mcp__perplexity-ask__perplexity_ask({
  messages: [{
    role: "user",
    content: "I'm getting error: $ERROR_MSG. Context: $CONTEXT. I've tried $ATTEMPTS different approaches. What am I missing?"
  }]
})
\`\`\`

**Then log findings:**
\`\`\`bash
./debugging/scripts/log-decision.sh investigation \\
  "Perplexity: [key findings here]"
\`\`\`

---

### 2. Brave MCP (Web Search)
\`\`\`typescript
mcp__brave-search__brave_web_search({
  query: "$QUERY_1",
  count: 10
})

// Also try:
mcp__brave-search__brave_web_search({
  query: "$QUERY_2",
  count: 10
})
\`\`\`

**Then log findings:**
\`\`\`bash
./debugging/scripts/log-decision.sh investigation \\
  "Brave search results: [top 3 insights here]"
\`\`\`

---

EOF

# Add Context7 section if API-related
if [ "$PROBLEM_TYPE" = "api" ] || [ "$PROBLEM_TYPE" = "unknown" ]; then
    cat >> "$RESEARCH_FILE" <<EOF
### 3. Context7 MCP (API/Library Docs)
\`\`\`typescript
// First, resolve the library ID:
mcp__context7__resolve-library-id({
  libraryName: "[library-name-here]"
})

// Then get docs:
mcp__context7__get-library-docs({
  context7CompatibleLibraryID: "/org/project",
  topic: "$CONTEXT7_TOPIC",
  tokens: 5000
})
\`\`\`

**Then log findings:**
\`\`\`bash
./debugging/scripts/log-decision.sh investigation \\
  "Context7 docs: [relevant sections here]"
\`\`\`

---

EOF
fi

# Add WebSearch fallback
cat >> "$RESEARCH_FILE" <<EOF
### 4. WebSearch (Fallback)
\`\`\`typescript
WebSearch({
  query: "$QUERY_1"
})
\`\`\`

---

EOF

# Add Gemini section if requested
if [ "$USE_GEMINI" = true ]; then
    cat >> "$RESEARCH_FILE" <<EOF
### 5. Gemini Skill (Alternative AI Perspective)

**If gemini skill is available, use it to get a fresh perspective:**

Provide Gemini with:
- Original error: $ERROR_MSG
- Context: $CONTEXT
- All $ATTEMPTS attempts and why they failed
- Search results from Perplexity, Brave, Context7
- Ask: "What am I missing? What should I try next?"

**Then log findings:**
\`\`\`bash
./debugging/scripts/log-decision.sh investigation \\
  "Gemini insight: [key observation]. Suggested: [recommendation]"
\`\`\`

---

EOF
fi

# Add synthesis section
cat >> "$RESEARCH_FILE" <<EOF
## Synthesis

After gathering all research, synthesize findings:

\`\`\`bash
./debugging/scripts/log-decision.sh decision \\
  "Based on research: [summarize key insights]. NEW approach: [what you'll try]"

./debugging/scripts/log-decision.sh rationale \\
  "This differs from previous attempts by: [key differences]"
\`\`\`

---

## Outcome

After trying the new approach, document:

\`\`\`bash
# If successful:
./debugging/scripts/log-decision.sh milestone \\
  "UNSTUCK via [which resource]. Root cause: [explanation]. Solution: [what worked]"

# If still stuck:
./debugging/scripts/log-decision.sh investigation \\
  "Get Unstuck protocol completed. Still blocked. Research summary: [findings]. Requesting human assistance."
\`\`\`

EOF

# Final logging
echo "[$(date +%H:%M:%S)] ✅ Get Unstuck protocol setup complete" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"
echo "**Next steps:**" >> "$LOG_FILE"
echo "1. Review research file: $RESEARCH_FILE" >> "$LOG_FILE"
echo "2. Execute searches manually (Perplexity, Brave, Context7, WebSearch)" >> "$LOG_FILE"
if [ "$USE_GEMINI" = true ]; then
    echo "3. Consult Gemini skill with findings" >> "$LOG_FILE"
    echo "4. Synthesize all findings" >> "$LOG_FILE"
    echo "5. Try new approach based on research" >> "$LOG_FILE"
else
    echo "3. Synthesize findings" >> "$LOG_FILE"
    echo "4. Try new approach based on research" >> "$LOG_FILE"
fi
echo "6. Document outcome (unstuck or still stuck)" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Output to terminal
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          GET UNSTUCK PROTOCOL ACTIVATED                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Research plan created: $RESEARCH_FILE"
echo ""
echo "🎯 Problem Type: $PROBLEM_TYPE"
echo "🔄 Attempts: $ATTEMPTS"
echo ""
echo "📡 Available Research Channels:"
echo "   ✓ Perplexity MCP (AI-powered search)"
echo "   ✓ Brave MCP (web search)"
if [ "$PROBLEM_TYPE" = "api" ]; then
    echo "   ✓ Context7 MCP (API/library docs) ← RECOMMENDED for API issues"
fi
echo "   ✓ WebSearch (built-in fallback)"
if [ "$USE_GEMINI" = true ]; then
    echo "   ✓ Gemini skill (alternative AI perspective)"
fi
echo ""
echo "📝 Next Steps:"
echo "   1. Open: cat $RESEARCH_FILE"
echo "   2. Execute searches as shown in research file"
echo "   3. Log findings using log-decision.sh investigation"
echo "   4. Synthesize and try new approach"
echo "   5. Document outcome"
echo ""
echo "All activity has been logged to: $LOG_FILE"
echo ""

exit 0
