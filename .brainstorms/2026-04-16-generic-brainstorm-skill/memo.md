# Decision Memo — generic-brainstorm skill (`/brainstorm`)

## What I want

A user-invocable Claude Code skill called `/brainstorm` that provides a **structured brainstorm protocol** for any non-code-specific thinking-through task: product decisions, writing direction, architecture choices, research questions, career/work decisions, hypothesis generation.

Unlike Claude's default collaborative-thinking behavior, this skill provides:
- Persistent working memory (indexed notepad across turns)
- Explicit phase transitions (Phase A map consent → Phase B lens rotation → Done Signal → Memo)
- A mentor-style circuit breaker that knows when to stop ("enough for today — pick up tomorrow") with session pause/resume
- Honest, professional coaching voice (Socratic, pressure-testing, no drip-feed, knows when to agree)

Sibling to `/skill-brainstorm` (skill-design-specific), parallel to future `/agent-brainstorm` (agent-to-agent, out of scope here).

## Why Claude needs it

**Concrete failure modes this injection addresses:**

1. **Drip-feed exhaustion.** Without structure, Claude surfaces one concern, refines it, then surfaces the next, then the next — forcing the user to ask "anything else?" repeatedly. The Opening Inventory rule (by end of Phase A, all major concerns named; Phase B refines, doesn't discover) kills this pattern.

2. **Brainstorm spirals.** Default collaborative thinking has no Done Signal — it continues until the user calls it. The mentor circuit breaker (diminishing-returns diagnostic + Pause move + suspend-resume protocol) gives the coach permission to say "enough for today."

3. **Lost threads across turns.** In long sessions, threads from early turns drift out of Claude's attention. Indexed notepad with per-turn updates + Circle-back move + Connections cross-references keep the full thread map alive.

4. **Cheerleader drift.** Without enforcement, collaborative thinking leans agreeable. Thread-resolution precondition (must pass 2 universal lenses before Agree) makes agreement earned, not free.

5. **Scope-shape confusion.** Users invoke brainstorms for different outcomes (decision / plan / spec / reframe) but default behavior produces variable output. Type × shape classification in Phase A previews memo format so users know what they're getting.

**What the superpowers `/brainstorming` skill gets wrong** (studied for comparison):
- Always produces a spec (no "not worth pursuing" exit)
- Hard-coupled to code/implementation flow
- No notepad (relies on LLM memory + final spec file)
- No circuit breaker — continues indefinitely until user approves
- Too-broad trigger ("MUST use before any creative work") causes routing unreliability

## Injection shape

**Primarily workflow + policy, secondarily domain knowledge.**

- **Workflow:** Phase A → Phase B → Done Signal → Memo state machine; notepad-updated-every-turn protocol; 7 moves as the Phase B action set; lens rotation protocol.
- **Policy:** coaching voice (Socratic, rational-over-agreeable, admits Phase A misses, knows when to pause); thread-resolution precondition (lens-gate for Agree); Opening Inventory rule; no-artifact-exits-are-valid.
- **Domain knowledge:** the 7-outcome-shape taxonomy, the 5-brainstorm-type taxonomy, the 7 generic lenses and their selection rules, the mentor circuit breaker heuristics.

Not a formatting injection (output shape is a consequence of classification, not a template fill-in).

## What it produces

**Primary artifact:** `memo.md` at `.brainstorms/<YYYY-MM-DD-slug>/memo.md` (project-local default when in git repo, `~/.claude/brainstorms/` fallback). Memo content varies by outcome shape:

| Shape | Memo content |
|---|---|
| Decision | Options considered, tradeoffs, recommendation, rationale |
| Plan | Ordered steps, dependencies, sequencing rationale |
| Spec | Structured "what to build" description |
| Reframe | Original framing, revised framing, why the shift |
| Decompose | Sub-topics named, sequencing, which to brainstorm next |
| Defer | What info is needed, revisit conditions (no memo — just a status note) |
| Abandon | Why not pursued, what surfaced along the way (no memo — just a status note) |

**Secondary artifact:** `notepad.md` (live working memory) and `meta.yaml` (session metadata). These survive the session for audit/resume.

**Handoff:** Memo includes a prose "you might consider X next" suggestion. No deterministic shape→skill map. User decides what to do with the memo.

## Edge cases considered

**Input ambiguity:**
- `/brainstorm` invoked with no topic → list recent paused/done sessions, offer resume or start new.
- Topic doesn't fit any (type, shape) cleanly → coach asks diagnostic questions before classifying (coaching-policy.md diagnostic mode).
- Classification drifts mid-session (e.g., decision → reframe) → coach updates (type, shape), adjusts lens subset, notes the shift. Permission granted, not a bug.

**Session-state corruption:**
- Notepad manually edited between turns → coach trusts the edit (notepad is source of truth).
- `meta.yaml` missing/corrupt → loud failure; offer fresh start or reconstruct from notepad.
- Same-day same-slug collision → second invocation finds the existing session and offers resume.

**Coach failure modes:**
- Premature convergence → Circle-back move reopens any thread closed without lens rotation.
- Cheerleader drift → structurally prevented by lens-gate precondition for Agree.
- Memo produced before Done Signal → refused with specific hanging threads named.
- Late-surfacing first-order concerns in Phase B → explicit admission protocol: name the miss, add to inventory, **sweep prior decisions for downstream invalidation**, continue.

**Infrastructure failure:**
- `.brainstorms/` missing → coach creates silently.
- File I/O fails mid-session → loud acknowledgment with the notepad delta included in response so user can copy manually.
- Not inside git repo → fall back to global `~/.claude/brainstorms/`.

**Boundary failures:**
- User invokes on skill-shaped topic → redirect to `/skill-brainstorm`.
- User has clear spec/plan already (no direction ambiguity) → redirect to appropriate implementation skill. (Direction-based, not verb-based — "build a dashboard" with no direction IS a brainstorm; "implement this spec" with a clear spec is not.)
- User wants full pipeline (brainstorm → code → docs) → redirect to `/autonomous-orchestrator`.
- Factual question with a clear answer → just answer, don't brainstorm.

**Thread tracking failures:**
- Threads lost in long sessions → indexed thread IDs (`T1`, `T2`, ...) + Circle-back move as a valid anytime move + Connections cross-reference section.

## Companion files anticipated

### references/ — domain knowledge loaded on-demand

- **`moves.md`** — the 7 moves (Generate / Pressure-test / Agree / Reframe / Decompose / Circle-back / Pause) with diagnostic questions for when each fires and state transition effects. Loaded at Phase B entry.
- **`brainstorm-types.md`** — the 5 types (decision / exploratory / problem / creative / planning) with diagnostic questions for classification. Loaded at Phase A classification.
- **`lens-catalog.md`** — the 7 generic lenses (Stakeholder / Alternative / Failure-mode / Cost / Reversibility / Time / Constraint) with diagnostic questions and per-type selection table (2 universal + 2 type-specific = 4 per session). Loaded at Phase B entry.
- **`coaching-policy.md`** — generic variant of skill-brainstorm's coaching-policy. Diagnostic mode, anchoring guard, rationality-over-agreeableness, agree-when-convinced, never-produce-memo-prematurely, **admission protocol with downstream-effect sweep**. Loaded at skill entry.
- **`wrong-tool-detection.md`** — direction-based exclusion rules, the 5 collision points, handoff suggestions. Loaded at skill entry.
- **`mentor-circuit-breaker.md`** — diminishing-returns diagnostic (LLM judgment, no hardcoded thresholds); user-prompt protocol ("feels like we're circling on T7 — fresh angle or pause?"); Pause move mechanics (set `status: paused` in meta.yaml, end session cleanly). Loaded when circuit breaker fires.

### templates/ — output format skeletons

- **`notepad.md`** — indexed thread structure (`T1`, `T2`, ...) with Status, Body, Depends-on, Connections section, Resolution log. Updated every turn.
- **`memo.md`** — seven shape-specific sections conditionally populated based on outcome shape. Includes prose "next steps" suggestion, no deterministic shape→skill map.
- **`meta.yaml`** — `schema_version: 1` + `status` (active/paused/done/abandoned) + `topic` + `slug` + `type` + `shape` + `scope` (project/global) + `last_updated`.

## Out of scope (document explicitly in SKILL.md)

- Formal decision analysis (weighted criteria matrices, MCDA, quantitative ranking).
- Multi-stakeholder facilitation — single-user tool.
- External research fetch/synthesis — user brings context in.
- Artifact production (spec, plan, code) — stops at memo.
- End-to-end pipeline drive — use `/autonomous-orchestrator`.
- Agent-to-agent brainstorm — future separate skill (`/agent-brainstorm`).

## Open questions (for `/skill-creator` Phase 1)

These are the remaining uncertainties worth resurfacing during creation rather than re-deriving:

1. **Description routing reliability.** Trigger phrase list ("help me think through," "I'm debating," "should I," "I have an idea for," "I'm not sure how to approach") is explicit, but real routing reliability is only measurable post-release via EVAL.md. Expect first-week drift correction.

2. **Type taxonomy practical validation.** 5 types (decision / exploratory / problem / creative / planning). Exploratory/planning boundary is crisp in theory (options known vs unknown) but may blur in practice. Revisit after ~10 real sessions.

3. **Lightweight mode trigger calibration.** Coach-decided based on Phase A inventory size (≤3 concerns + single-question scope → offer quick mode). Threshold may need tuning.

4. **Pipeline unification with built-in `brainstorm` stage (Option B from registry check).** Currently coexisting (Option A). Future refactor: this skill becomes the implementation of the built-in stage, producing `design_sketch` typed output when invoked inside `/autonomous-orchestrator`. Not needed for initial release.

5. **Memo shape coverage completeness.** Seven shapes (Decision / Plan / Spec / Reframe / Decompose / Defer / Abandon). If real usage reveals an eighth, the taxonomy grows — but the move set and phase structure should not change.

## Follow-up tasks (tracked separately, not part of this skill's initial release)

1. **Port mentor circuit breaker + Opening Inventory rule + admission protocol (with downstream sweep) back to `/skill-brainstorm`.** Same failure modes exist there; same fixes apply. Sister refactor.

2. **Evaluate reference-file sharing between `/brainstorm` and `/skill-brainstorm`.** If `coaching-policy.md` or any other reference turns out nearly identical, consider a repo-level `common/` directory with symlinks. Not required; evaluate during follow-up #1.

3. **Consider `/agent-brainstorm` as a separate future sibling.** Agent ↔ agent, invoked by other skills, no user consent gates, Done Signal = agent consensus.

4. **Unify with built-in `brainstorm` stage (Option B).** Registry refactor; `/brainstorm` becomes the implementation of the pipeline stage when invoked by orchestrator.

5. **General CLAUDE.md rule for non-brainstorm drip-feed** ("for discovery questions, exhaustively enumerate on first pass, don't drip-feed across follow-ups"). Separate from this skill; broader behavior fix.
