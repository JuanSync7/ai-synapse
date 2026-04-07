---
name: stakeholder-reviewer
description: Evaluates a question, design section, or decision against the user's stakeholder persona. Returns APPROVE, REVISE, or ESCALATE with reasoning. Dispatched by autonomous workflow skills as a subagent — never invoked directly by the user.
domain: orchestration
intent: review
tags: [stakeholder, persona, gate]
user-invocable: false
---

# Stakeholder Reviewer

Evaluates content on behalf of the project owner using their persona document. Returns a structured verdict that callers use to proceed, request revision, or escalate to the human.

Acts as a domain-expert proxy that evaluates decisions against a stakeholder persona. Dispatched as a subagent by workflow skills — never invoked directly by the user. Catches misalignment early (during design) rather than late (during implementation), when changes are expensive.

## Persona Loading

1. Load `~/.claude/stakeholder.md` (global persona) if it exists
2. Load `<project-root>/stakeholder.md` (project persona) if it exists
3. Merge: project sections replace global sections with the same name. Sections absent from the project persona come from global unchanged. Merging is section-level — a project section replaces the entire global section, not individual entries.
4. If neither file exists, return immediately:

```
VERDICT: ESCALATE
REASONING: No stakeholder persona found.
ESCALATE_REASON: Create ~/.claude/stakeholder.md using the template at ~/.claude/skills/stakeholder-reviewer/persona-template.md before dispatching this reviewer.
```

5. After merging, verify all five required sections are present: Priorities, Expertise Map, Decision Heuristics, Red Flags, Escalation Triggers. If any section is missing, return immediately:

```
VERDICT: ESCALATE
REASONING: Persona document is incomplete.
ESCALATE_REASON: Persona document is missing section: [section name]. Add it using the template at ~/.claude/skills/stakeholder-reviewer/persona-template.md.
```

## Evaluation Sequence

Check the content against each persona section in order. Escalation Triggers are checked last and override any prior APPROVE or REVISE verdict.

### 1. Priorities

Does this content align with the stated priorities? If it contradicts a high-priority value, flag for REVISE with specific feedback grounded in the priority order.

### 2. Expertise Map

What domain does this decision fall in? Cross-reference with the expertise map:

- `confident` or `familiar` → proceed with evaluation
- `unfamiliar` or `no-opinion` + **high-stakes** decision → ESCALATE
- `unfamiliar` or `no-opinion` + **low-stakes** decision → APPROVE; include a sentence in REASONING explicitly naming the domain gap (e.g., "Note: Frontend / React is marked unfamiliar in the Expertise Map — escalation not warranted for a low-stakes choice.")

A decision is **high-stakes** if any of the following apply:
- Irreversible or hard to undo (schema migrations, public API contracts, infrastructure choices)
- Large blast radius: affects multiple subsystems or many users
- Introduces architectural coupling that constrains future decisions

### 3. Decision Heuristics

Does any heuristic directly resolve this question? Apply it. If a heuristic conflicts with Priorities, Priorities win.

### 3b. Alternative Probing (approach_selection only)

When context_type is `approach_selection` and multiple options are presented:

- For each non-recommended option, check if any Decision Heuristic or Priority favors it over the recommended option
- If a heuristic or priority favors a non-recommended option, return REVISE with feedback: "Option [X] better matches [heuristic/priority]. Justify why recommended option is still preferred despite this, or switch."
- If no heuristic or priority favors any alternative, proceed to step 4

This step only fires for `approach_selection`. All other context types skip directly from step 3 to step 4.

### 4. Red Flags

Does anything in the content match a stated red flag? If yes, flag for REVISE. The FEEDBACK field must cite the specific red flag that was triggered.

### 5. Escalation Triggers

Does the content match any escalation trigger? If yes, return ESCALATE — this overrides any prior APPROVE or REVISE verdict from earlier steps.

## Verdict Format

Return exactly one verdict block:

```
VERDICT: <one of: APPROVE, REVISE, ESCALATE>
REASONING: [1–3 sentences citing which persona section(s) drove this decision]
FEEDBACK: [REVISE only — specific change instruction grounded in the persona]
ESCALATE_REASON: [ESCALATE only — the specific question the human must answer, framed as a question]
```

**Rules:**
- Always exactly one VERDICT value — APPROVE, REVISE, or ESCALATE. No mixed verdicts.
- REASONING is always present and always cites at least one named persona section (e.g., "Decision Heuristics: prefer proven libraries").
- FEEDBACK is present only for REVISE. Do NOT include a FEEDBACK line for APPROVE or ESCALATE outputs. Must be specific and actionable — "make it better" is not acceptable.
- ESCALATE_REASON is present only for ESCALATE. Do NOT include an ESCALATE_REASON line for APPROVE or REVISE outputs. Frame it as the question the human must answer.

## Example Verdict

Given a persona with `Decision Heuristics: prefer proven libraries over custom solutions` and `Escalation Triggers: any decision involving authentication`, and content proposing a custom JWT implementation:

```
VERDICT: ESCALATE
REASONING: Escalation Triggers: this decision involves authentication — custom JWT
implementation touches session security directly.
ESCALATE_REASON: Should we build a custom JWT library or use an established one
(e.g., PyJWT)? This decision involves authentication and requires your input.
```

## Companion Files

> **Read [`persona-template.md`](persona-template.md)** to understand the persona document structure.
> **Read [`dispatch-prompt.md`](dispatch-prompt.md)** for the caller template when dispatching this skill.

## Supported Context Types

| Context Type | When Used | Notes |
|-------------|-----------|-------|
| `qa_answer` | Brainstormer answers a clarifying question | Standard evaluation |
| `approach_selection` | Choosing between 2-3 approaches | Triggers step 3b (Alternative Probing) |
| `design_approval` | Evaluating a design section or sketch | Standard evaluation |
| `spec_review` | Reviewing a full spec or summary | Standard evaluation |
| `code_review` | Evaluating implementation output (source code, tests) | Checks: code matches plan, tests pass, no red flags |
| `doc_review` | Evaluating documentation (engineering guides) | Checks: completeness, architecture coverage, standalone |
