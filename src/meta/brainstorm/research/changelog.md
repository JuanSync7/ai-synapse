# brainstorm — Auto-Research Changelog

**Run:** 2026-04-16 | Branch: `autoresearch/brainstorm-2026-04-16`
**Baseline:** 15/20 | **Final:** 20/20 | **Iterations:** 4 (3 kept, 0 reverted)

---

## Iteration 002 — Notepad-first turn structure (EVAL-O12)
**Commit:** e48f240 | Score: 15/20 → 18/20 (+3)

**Problem:** SKILL.md stated "Update the notepad BEFORE composing each response" but gave no structural enforcement. An agent naturally composes the response first, then updates the notepad retroactively. EVAL-O12 failed because responses could reference thread states not yet reflected in the notepad.

**Change:** Replaced the single imperative line in Phase B with an explicit numbered turn structure:
> 1. **Write notepad** — update with current thread states, lenses applied, observations. Before any response text is composed.
> 2. **Compose response** — derive what to say from the notepad state just written. Never reference thread state not yet in the notepad.

**Why it worked:** Making the two steps explicit and numbered removes ambiguity about ordering. "Write then compose" is causally prior — the response is derived FROM the notepad, not the other way around. EVAL-O12 confirmed; adversarial simulation also confirmed EVAL-O03 and EVAL-O10.

---

## Iteration 003 — Auditable lens gate before Agree (EVAL-O03)
**Commit:** 38c5421 | Score: 18/20 → 19/20 (+1)

**Problem:** The Agree move required both Stakeholder and Alternative lenses applied before resolving a thread, but the check was a silent self-diagnostic. The gate was only verifiable by inspecting the notepad — no artifact in the response text confirmed the gate fired. An evaluator couldn't distinguish "gate checked and passed" from "gate skipped."

**Change:** Added a required gate output to the Agree move in references/moves.md:
> **Required gate output:** Before issuing Agree, you MUST produce a visible confirmation line in your response:
> `Stakeholder ✓ T[n], Alternative ✓ T[n] — gate passes`
> If either lens has not been applied, produce `Stakeholder ✗ T[n]` or `Alternative ✗ T[n]` and apply the missing lens first.

**Why it worked:** The gate now produces an auditable artifact in the response text, not just the notepad. EVAL-O11 (Pause protocol) and EVAL-O13 (Defer/Abandon no-memo) also confirmed passing via Pause and Defer scenario simulations.

---

## Iteration 004 — Operational admission protocol trigger (EVAL-O02)
**Commit:** 2ea7667 | Score: 19/20 → 20/20 (+1)

**Problem:** The admission protocol in coaching-policy.md said "when a first-order concern surfaces in Phase B" but gave no heuristic for what makes a concern first-order. An agent would always rationalize that a Phase B concern was derived ("I only knew this after examining T2") and never fire the admission protocol. EVAL-O02 failed because the trigger condition was conceptual, not operational.

**Change:** Added a concrete decision rule to the Admission Protocol section in references/coaching-policy.md:
> **First-order (admission fires):** Identifiable from the original topic statement alone, without examining any specific thread content. A reader of the raw topic would say "yes, that's an obvious angle."
> **Derived (no admission needed):** Only becomes visible after exploring a specific thread's internal logic — depends on knowing the content of T2 or T3 to surface.
> **Test:** "Would this concern appear in a Phase A Opening Inventory by a competent coach who read the topic description and nothing else?"

**Why it worked:** The decision rule transforms an ambiguous policy ("is it first-order?") into a concrete test ("could a competent coach have listed it from the topic alone?"). The agent now has a definitive trigger rather than a rationalization escape hatch. EVAL-O08, O09, O17, O20 also verified passing via their respective scenario simulations.

---

## Summary

All 3 improvements target the same root pattern: **protocol rules that stated the constraint but gave no enforcement mechanism.**

| Gap | Root cause | Fix |
|---|---|---|
| EVAL-O12 | "update before composing" had no structural order enforcement | Explicit numbered two-step sequence |
| EVAL-O03 | lens gate was silent — no auditable artifact | Required gate confirmation line in response text |
| EVAL-O02 | "first-order" had no operational definition — agent rationalized | Concrete topic-description-alone decision rule |
