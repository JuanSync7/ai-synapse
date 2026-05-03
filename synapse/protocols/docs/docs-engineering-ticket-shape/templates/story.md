---
id: FR-NNN
title: <title>
phase: 1
status: skeleton
modules: []
touches: []
touches_function: []
depends_on: []
conflicts_with: []
acceptance_criteria:
  - <AC 1 — observable, testable, specific>
  - <AC 2>
owner: <agent-id | human-id>
labels: []
version: 1
---

# <Story Title>

## What

<2-4 sentence description of the observable behavior change this FR delivers. WHAT users / callers / operators see, not HOW it works internally.>

## Why

<1-2 sentences linking this FR to the epic goal or a vocab term. The motivation, not the algorithm.>

## Observable Behavior

<Bulleted list of behaviors a black-box observer would notice. Frame each as an outcome ("Given X, the system Y") not a mechanism.>

- Given <input>, the system produces <output>.
- When <condition>, <observable signal>.

## Edge Cases

<Edge cases as outcomes, not as algorithm branches. "On empty input, returns empty result" — yes. "If buffer is null, allocate a new one" — no, that's design.md.>

- Empty / boundary input → <outcome>
- Failure of dependency → <outcome>
- Concurrent access → <outcome>

## References

- vocab: <term-1>, <term-2>
- epic: [<epic-name>](../../../../epic.md)
- depends_on (frontmatter only): <FR-NNN if present>

---

<!--
Template usage notes:

- AC are AUTHORITATIVE in frontmatter. The body MUST NOT duplicate, restate, or paraphrase the AC list. Reference by ID or skip — never re-list.
- WHAT only. Algorithms, data structures, internal interfaces, and specific implementation decisions belong in design.md.
- `phase:` MUST equal the integer in the directory path (`phases/phase-<N>/`).
- `version:` MUST equal the protocol version.
- `depends_on` and `conflicts_with` MUST be within-phase only. Cross-phase coordination flows through epic.md and engineering_guide.md.
- Forbidden frontmatter fields: `branch:`, `created:`, `shipped:`, `breaking_change:`, `extends:`, `supersedes:`. Branch derives from `feature/<system>/<phase>/<fr-slug>`. Created/shipped derive from git. Use the `breaking` label for breaking changes.
- DO NOT add an `## Activity` section. Process exhaust lives in git log; non-obvious decisions live in impl.md.
-->
