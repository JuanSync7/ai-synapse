# Stakeholder Reviewer — Dispatch Template

Use this template when dispatching the stakeholder-reviewer as a subagent from another workflow.

**Prerequisites:** The subagent environment must support the Skill tool (Claude Code). The `stakeholder-reviewer` skill must be installed at `~/.claude/skills/stakeholder-reviewer/`.

**Fill in all five placeholders. Do not modify the skill reference line.**

---

```
Task tool (general-purpose):
  description: "Stakeholder review — [LABEL]"
  prompt: |
    You are a stakeholder reviewer. Evaluate the following on behalf of the
    project owner using their persona document.

    **Global persona:** ~/.claude/stakeholder.md
    **Project persona:** [PROJECT_ROOT]/stakeholder.md

    **Context type:** [CONTEXT_TYPE]

    **Caller context:**
    [CALLER_CONTEXT]

    **Content to evaluate:**
    [CONTENT]

    Evaluate using the skill:
    Skill tool: stakeholder-reviewer

    Return the verdict in the format defined by the skill.
```

---

## Placeholder Reference

| Placeholder | What to fill in | Example |
|-------------|----------------|---------|
| `[LABEL]` | Short description for the task log | `approach selection — database choice` |
| `[PROJECT_ROOT]` | Absolute path to the project root | `/home/user/myproject` |
| `[CONTEXT_TYPE]` | Category of decision | `qa_answer` \| `approach_selection` \| `design_approval` \| `spec_review` |
| `[CALLER_CONTEXT]` | 1–2 sentences: what workflow dispatched this and what stage you are at | `This is the autonomous-brainstorm skill at the approach selection stage. The brainstormer has proposed three architecture options and needs a verdict on which to proceed with.` |
| `[CONTENT]` | The question, design section, or decision to evaluate | Paste verbatim. Use a fenced block for structured content (YAML, numbered lists, code). Include enough context that the reviewer can evaluate without prior conversation history. |

## Context Type Guide

| Type | When to use |
|------|-------------|
| `qa_answer` | Brainstormer asked a clarifying question and proposes an answer |
| `approach_selection` | Brainstormer proposes 2–3 approaches and needs a verdict |
| `design_approval` | Brainstormer presents a design section for approval |
| `spec_review` | Full spec or summary presented for final approval |
