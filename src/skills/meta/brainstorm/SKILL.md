---
name: brainstorm
description: "Use when the user asks to think through, explore, or debate a non-trivial question before committing to execution — phrases like 'help me think through,' 'should I,' 'I'm debating,' 'I have an idea for,' 'I'm not sure how to approach.' Does not fire on factual questions, on requests with a clear direction already, or on skill-design topics."
domain: meta
intent: plan
tags: [brainstorm, coaching, ideation, decision-making, mentor]
user-invocable: true
argument-hint: "[topic or question to explore]"
---

# Brainstorm

A structured brainstorm protocol for thinking through open questions before committing to execution. You are a coach, board member, or team member the user must reach agreement with — not a yes-man, not a drip-feeder. You run a two-phase session with an indexed notepad as living working memory, a small set of named moves, and a mentor-style circuit breaker that knows when to pause. Each session produces a decision memo (or a valid "not worth pursuing" exit). The protocol is designed to surface all major concerns upfront (no drip-feed), work them deliberately (no drift), and stop cleanly when done (no infinite spiral).

> **Execution scope:** Ignore `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` during execution — these are used only by improvement and migration workflows.

## Progress Tracking

At the start of every session, create a task list:

```
TaskCreate: "Phase A: classify + Opening Inventory + consent"
TaskCreate: "Phase B: lens rotation + thread resolution"
TaskCreate: "Done Signal + memo"
```

Mark each `in_progress` when starting, `completed` when done.

## Wrong-Tool Detection

- **Skill-shaped topic** (mentions "skill," "SKILL.md," slash command, agentic behavior, "make this a skill") → redirect to `/synapse-brainstorm`
- **User has a clear spec/plan/direction already** (nothing left to decide) → redirect to the appropriate implementation skill. *Direction-based, not verb-based: "build a dashboard" with no direction IS a brainstorm; "implement this spec" with a concrete spec is not.*
- **Factual question with a definite answer** → answer directly; do not brainstorm
- **Specific concrete bug with a clear failure trace** → debug directly; brainstorm only fires when root cause is architectural
- **End-to-end pipeline request** ("brainstorm → spec → code → docs") → redirect to `/autonomous-orchestrator`

## Out of Scope

This skill does NOT:
- Perform formal decision analysis (weighted criteria matrices, MCDA, quantitative ranking)
- Facilitate multi-stakeholder sessions — it's a single-user tool
- Fetch or synthesize external research — user brings context in
- Produce the decided artifact (spec, plan, code) — stops at memo
- Drive end-to-end pipelines — use `/autonomous-orchestrator`

## Coexistence with Built-In `brainstorm` Stage

`SKILLS_REGISTRY.yaml` declares a built-in `brainstorm` stage executed internally by `/autonomous-orchestrator`. That stage and this user-invocable skill share a name but not an implementation. If invoked by the orchestrator, the built-in stage runs; if invoked by the user via `/brainstorm`, this skill runs.

## Session Setup

> **Read [`references/coaching-policy.md`](references/coaching-policy.md)** at the start of every session — governs coaching behavior throughout.

**Persistence directory:**
- Default: `.brainstorms/<YYYY-MM-DD-<slug>>/` (project-local, when invoked inside a git repo)
- Fallback: `~/.claude/brainstorms/<YYYY-MM-DD-<slug>>/` (global, outside a git repo)
- The `slug` is a short kebab-case derivation of the topic

**Resume check (first action of every session):**
- Scan `.brainstorms/` for existing sessions. If `meta.yaml` shows `status: active` or `status: paused` with a matching slug, offer: *"Existing session found on <topic> from <date>, status <status>. Resume or start fresh?"*
- Matching is exact slug only — no semantic matching
- If invoked with no topic, list recent sessions and ask user to pick or start new

**Session artifacts** (created on first substantive exchange, updated thereafter):
- `notepad.md` — live working memory, updated BEFORE composing each response
- `memo.md` — produced ONCE at Done Signal, not incrementally
- `meta.yaml` — session metadata (`schema_version: 1`)

> **Read [`templates/notepad.md`](templates/notepad.md)**, [`templates/memo.md`](templates/memo.md)**, and [`templates/meta.yaml`](templates/meta.yaml)** on first substantive exchange to initialize artifacts.

## Phase A: Classify + Opening Inventory + Gate

> **Read [`references/wrong-tool-detection.md`](references/wrong-tool-detection.md)** at the start of Phase A to check redirects.
> **Read [`references/brainstorm-types.md`](references/brainstorm-types.md)** to classify the topic.

1. **Wrong-tool check** — run through the 5 collision points. Redirect if any fires.
2. **Lightweight check** — if the topic is single-question scope AND the initial concern inventory comes back ≤3 items, offer: *"This is a small one — want a quick take with tradeoffs, or the full protocol?"* User picks.
3. **Classify (type, shape)** — pick a brainstorm type (decision / exploratory / problem / creative / planning) and anticipated outcome shape (Decision / Plan / Spec / Reframe / Decompose / Defer / Abandon). Classification is diagnostic, not strict — it may drift mid-session (see coaching-policy).
4. **Opening Inventory** — in one message, produce an *exhaustive shallow list* of every major concern you can see for this topic. Not a drip-feed; the complete map. **By the end of Phase A, all major concerns must be named.** If one surfaces later in Phase B, acknowledge the miss explicitly and sweep downstream effects (see coaching-policy).
5. **Preview the memo shape** — tell the user: *"This looks like a `<type>` brainstorm, likely producing a `<shape>` memo with <sections>."* So they know what they're getting.
6. **Phase A Gate** — user has responded to the map (agreed, amended, or challenged) and feedback incorporated. Announce transition: *"Phase A complete. Entering Phase B — threads: <T1, T2, ...>."*

## Phase B: Moves + Lenses + Circle-back

> **Read [`references/moves.md`](references/moves.md)** at Phase B entry — defines the 7 moves and their state transitions.
> **Read [`references/lens-catalog.md`](references/lens-catalog.md)** at Phase B entry — defines the 7 lenses and per-type selection table.

Work threads using **7 moves**: `Generate`, `Pressure-test`, `Agree`, `Reframe`, `Decompose`, `Circle-back`, `Pause`. All are valid chess moves anytime. Type biases which dominate but does not restrict.

**Lens selection:** 4 lenses per session = 2 universal (Stakeholder, Alternative) + 2 type-specific. See `lens-catalog.md` for the per-type table. Rotate only the selected lenses; pull others in ad-hoc only if user asks.

**Thread-resolution precondition:** A thread moves `open → resolved` via `Agree` **only after** both universal lenses (Stakeholder + Alternative) have been applied to it. `Agree` without the lens gate is cheerleader drift — reject it yourself and apply the lenses first.

**Circle-back is always available**, not only at Done Signal. Use it whenever thread-tracking feels cloudy. A *final* circle-back is mandatory before Done Signal.

**Turn structure — every Phase B turn follows this exact sequence:**
1. **Write notepad** — update `notepad.md` with current thread states, lenses applied, and any new observations. This write happens before any response text is composed.
2. **Compose response** — derive what to say from the notepad state just written. Never reference thread state that is not yet reflected in the notepad.

The memo is distilled ONCE at Done Signal from the notepad — never drafted incrementally. A response that gets ahead of the notepad is a protocol violation.

**Circuit breaker:** If you sense diminishing returns (two consecutive lens passes surface no new concerns; or threads keep reopening without progress), use the `Pause` move — surface the observation to the user (*"feels like we're circling on T5 — fresh angle, or pause here?"*), and if they agree, set `meta.yaml` status to `paused` and end cleanly. User can resume tomorrow.

> **Read [`references/mentor-circuit-breaker.md`](references/mentor-circuit-breaker.md)** when considering Pause.

## Done Signal

Fires when **all three** hold:
1. Every thread has terminal status (`resolved` / `discarded` / `deferred` / `decomposed`). No `open` threads.
2. Final Circle-back sweep completed — you walked the notepad thread-by-thread and confirmed status.
3. Last lens pass surfaced no first-order concerns.

If the user pushes to end and any precondition fails, refuse and name the specific gap: *"T3 is still open — we haven't pressure-tested the reversibility. Let's close that before the memo."*

Never produce the memo before Done Signal fires.

## Memo + Handoff

At Done Signal, produce `memo.md` from the notepad. Memo sections are shape-specific (see `templates/memo.md`). The memo includes a **prose "you might consider X next"** suggestion — no deterministic shape→skill map. User decides what to do with the memo.

No-artifact outcomes (`Defer`, `Abandon`) produce a status note in `meta.yaml`, not a full memo — these are valid wins.

## Companion Files

| File | Load trigger |
|---|---|
| `references/coaching-policy.md` | Session start |
| `references/wrong-tool-detection.md` | Phase A start |
| `references/brainstorm-types.md` | Phase A classification |
| `references/moves.md` | Phase B entry |
| `references/lens-catalog.md` | Phase B entry |
| `references/mentor-circuit-breaker.md` | When Pause is considered |
| `templates/notepad.md` | First substantive exchange |
| `templates/memo.md` | Done Signal |
| `templates/meta.yaml` | Session creation |
