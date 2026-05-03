# <Story Title> — Implementation Notes

> Companion to [story.md](story.md) and [design.md](design.md). Captures non-obvious deviations, debugging discoveries, and decisions made under fire. NEVER a mechanical change log.

## Status

<One line. Current state: not started | in progress | shipped | rolled back.>

## Deviations from Design

<Where implementation diverged from design.md, and why. Each entry: what design.md said, what was actually done, the reason. If implementation matches design exactly, write "No deviations." — do not pad.>

- **<Aspect>** — design.md called for <X>; implementation uses <Y> because <reason discovered during build>.

## Debugging Discoveries

<Non-obvious behaviors uncovered during implementation. Things a future maintainer would re-discover painfully without this note. Each entry: the symptom, the root cause, the fix or workaround.>

- **<Symptom>** — root cause: <discovery>. Fix: <approach>.

## Decisions Under Fire

<Decisions made during implementation that weren't pre-planned in design.md. Trade-offs forced by reality (timing, dependency behavior, environment quirks). Each entry: the constraint, the decision, the alternative rejected.>

- **<Decision>** — Constrained by <reality>; chose <option> over <alternative> because <reason>.

## Open Questions

<Items that remain unresolved at ship time. Triaged for follow-up, not silently dropped. Each entry: the question, who owns it, the rough timeline.>

- <Question> — owner: <name>; deadline: <when>.

---

<!--
Template usage notes:

- This file is for NON-OBVIOUS content only. If the implementation matched design.md exactly and nothing surprising happened, this file says so in one line. Do NOT pad with mechanical change logs.

- FORBIDDEN content:
  - Mechanical change logs ("added X to module Y, then renamed Z")
  - Runtime CI results (test pass/fail counts, coverage percentages)
  - AC restatements (those live in story.md frontmatter)
  - Algorithm or data-structure descriptions (those live in design.md)
  - Test plans or assertion intent (those live in test.md)

- The bar: would a future maintainer re-discover this painfully without this note? If yes, write it. If no, omit.

- This file evolves DURING and AFTER implementation. Initial version (at story-writer time) may be a one-line placeholder ("No deviations yet — populate during implementation"). The implementer fills it in as work progresses.
-->
