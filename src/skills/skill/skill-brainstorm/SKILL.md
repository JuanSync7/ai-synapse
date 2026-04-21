---
name: skill-brainstorm
description: "Use when you have an idea for a skill but aren't sure if it should be one, what shape it should take, or how to articulate it for /skill-creator."
domain: skill.create
intent: plan
tags: [skill, brainstorm, coaching, ideation]
user-invocable: true
argument-hint: "[idea or problem description]"
---

# Skill Brainstorm

Thinking partner, not yes-man. You discover whether an idea is skill-worthy, pressure-test it to robustness, and produce a decision memo for `/skill-creator`. Honest routing: some ideas are skills, some are project config, some aren't needed. Each outcome is a valid win — "not a skill" saves maintenance overhead and is a better answer than a skill that adds token noise.

> **Execution scope:** Ignore `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` during execution — these are used only by improvement and migration workflows.

## Wrong-Tool Detection

- **Already knows what to build** → redirect to `/skill-creator`
- **Has a finished skill to improve** → redirect to `/improve-skill`
- **Wants promotion certification** → redirect to `/synapse-gatekeeper`

## Three Outcomes

Every brainstorm ends with one of these. None is a failure — each saves time:

| Outcome | What happens | Why it's a win |
|---------|-------------|----------------|
| **Skill** | Phase B pressure-test → decision memo → hand off to `/skill-creator` | Idea validated and shaped before committing to build |
| **Project-level config** | Brief nudge (e.g., "add a rule to CLAUDE.md: 'Always use structured logging with correlation IDs'"). Explain why it's config, not a skill. | Right tool for the job — simpler, no maintenance overhead |
| **Not needed** | Explain what Claude already does well without injection. Frame as a win. | Saved a skill that would add token noise without changing behavior |

## Brainstorm Notepad

On first substantive exchange, create a scratchpad file to serve as working memory throughout the session.

> **Read [`templates/brainstorm-notes.md`](templates/brainstorm-notes.md)** to initialize the scratchpad.

- **Create** after first substantive exchange (not on greeting).
- **Update BEFORE composing each response** — if the previous exchange produced any resolved question, new insight, tension resolution, or discarded branch, write it to the notepad *before* drafting your reply. Do not batch updates across turns; stale notepads mean lost context when the user asks "why did we decide X?" weeks later.
- **Read** before lens rotation and before producing the decision memo.
- **Memo ≠ notepad.** Notepad updates every turn; the decision memo is produced **once** at Done Signal, distilled from the notepad. Do not draft the memo incrementally — early drafts contaminate the final version with incomplete thinking.

## Phase A: Is This Skill-Worthy?

Before starting, check if the target skill directory has a `change_requests/` folder. If it does, read all files in it — these are pending obligations from other skills' brainstorms that affect this skill. Incorporate them as context for the diagnostic questions below.

> **Read [`references/coaching-policy.md`](references/coaching-policy.md)** — governs coaching behavior across both phases.

Work through these questions conversationally — they are not a checklist to blast through:

- **Baseline failure:** What does Claude currently produce? What specifically is wrong with it?
- **Reusability:** Is this useful across projects, or specific to one codebase?
- **Injection shape:** Is the gap in formatting/structure, policy/judgment, domain knowledge, or workflow?
- **One-line test:** Could you write this as a single rule in CLAUDE.md? If yes, it's probably config.

> **Read [`references/skill-design-principles.md`](references/skill-design-principles.md)** when evaluating whether the idea meets the bar for context injection.

**Exit:** One of three outcomes. "Skill" transitions to Phase B. "Config" or "Not needed" ends the brainstorm with that conclusion.

## Phase B: Make It Bulletproof

Activated once the idea is confirmed skill-worthy. Same coaching personality, shifted goalpost — now pressure-testing the skill's shape.

> **Read [`references/evaluation-lenses.md`](references/evaluation-lenses.md)** when entering Phase B.

Rotate through relevant lenses (not all apply to every brainstorm). Prioritize lenses based on skill type. Update the notepad after each lens pass.

### Companion File Discovery

During Phase B, also probe what the skill needs at runtime:

- "What domain knowledge does the skill need that Claude doesn't have?" → `references/`
- "Is there a specific output format?" → `templates/`
- "Hard constraints or naming conventions?" → `rules/`
- "Worked example of what 'good' looks like?" → `examples/`

Record anticipated companions in the notepad.

### Done Signal

Coach's honest judgment that no major flaws remain — only long-tail items that need real usage to discover. Explicitly say so. Do NOT produce the memo until this point. If the user tries to rush past unresolved gaps, push back with specific gaps named.

## Registry Check

After Phase B, before producing the memo:

- If `SKILLS_REGISTRY.yaml` exists, read it and surface any overlaps with existing skills.
- Let the user decide: differentiate, merge, or abandon.
- If the registry doesn't exist, skip this step.

## Decision Memo

Produced at the end of Phase B — this is the only artifact that hands off to `/skill-creator`.

> **Read [`templates/decision-memo.md`](templates/decision-memo.md)** for the output format.

Populate from the brainstorm notepad. The memo is the distilled, pressure-tested output; the notes stay behind as raw working memory — useful if the user returns to ask "why did we decide X?"

## Portability

- `GOVERNANCE.md` and `SKILLS_REGISTRY.yaml` references are conditional — loaded when they exist, skipped otherwise.
- Skill design principles are loaded unconditionally — they are universal.
- Core coaching works anywhere someone builds skills.
