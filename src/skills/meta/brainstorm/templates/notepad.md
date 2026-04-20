# Brainstorm Notes — <topic>

<!--
  Notepad protocol:
  - Update this file BEFORE composing every response. Stale notepads lose context.
  - Threads use indexed IDs (T1, T2, ...) for unambiguous reference.
  - The memo is distilled ONCE at Done Signal from this notepad — do not draft the memo incrementally here.
  - At Done Signal, every thread must be in a terminal state (resolved / discarded / deferred / decomposed). No `open`.
-->

## Status

- **Phase:** A | B | DONE | PAUSED
- **Type:** decision | exploratory | problem | creative | planning
- **Anticipated shape:** Decision | Plan | Spec | Reframe | Decompose | Defer | Abandon
- **Turn count:** <n>

## Threads (indexed)

### T1: <short title>
**Status:** open | resolved | discarded | deferred | decomposed
**Depends on:** <T-IDs, if any>
**Lenses applied:** Stakeholder ✓ | Alternative ✓ | <type-specific lenses>

<discussion body — concerns surfaced, options generated, pressure-test notes, resolution reasoning>

### T2: <short title>
**Status:** ...
**Depends on:** T1
**Lenses applied:** ...

<body>

<!-- Add T3, T4, ... as threads surface. Children of decomposed threads use dotted IDs: T5a, T5b, T5c. -->

## Connections

<!--
  Lightweight prose cross-references between threads. Not a formal graph — just "thread X relates to thread Y, here's how."
  Coach populates opportunistically during Reframe or Circle-back moves.
  Used for: downstream effect sweeps (admission protocol), memo coherence, Circle-back navigation.
-->

- T1 ↔ T3: resolution of T1 affects T3 (shared assumption on X)
- T5 discarded because T2 superseded it
- T7 simplified after T4 narrowed lens scope

## Resolution Log

<!--
  Timeline of thread closures. Turn number + final status + brief reason.
  Enables post-hoc review: "why did we decide T3 the way we did at turn 7?"
-->

- T1 resolved (turn 4) — <reason>
- T2 discarded (turn 5) — <reason>
- T5 decomposed (turn 7) → T5a, T5b, T5c
- T3 deferred (turn 9) — waiting on <external input>

## Key Insights

<!-- Things surfaced during the session that matter beyond a single thread. -->

## Tensions

<!-- Unresolved contradictions or tradeoffs that span multiple threads. Flag for memo or for user decision. -->

## Discarded Candidates (Moves, Framings, Options)

<!-- Things considered and rejected with reason. Prevents revisiting. -->

## Phase A Misses (if any)

<!--
  Per admission protocol (see coaching-policy.md), if a first-order concern surfaces in Phase B that
  should have been in the Opening Inventory, record it here with:
    - what was missed
    - which turn it surfaced
    - which prior decisions were flagged for re-examination
  The admission is the discipline.
-->
