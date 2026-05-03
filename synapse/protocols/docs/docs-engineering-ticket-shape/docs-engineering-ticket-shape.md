---
name: docs-engineering-ticket-shape
description: "Loaded by any agent writing or editing engineering pipeline docs (initiative.md, epic.md, vocab.md, story.md, design.md, impl.md, test.md, engineering_guide.md, INDEX.md). Defines directory layout, frontmatter schema, edge rules, eng-guide skeleton, and version policy."
domain: docs
type: schema
version: 1
tags: [engineering-docs, ticket-shape, vertical-slice]
---

# Docs Engineering Ticket Shape

## Mental Model

Engineering specs live as ticket-shape per-FR directories under an Initiative > Epic > Story > Subtask hierarchy. Without one source of truth for directory layout, frontmatter fields, edge semantics, and the engineering-guide skeleton, parallel agents drift — one writes `branch:`, another invents `created:`, a third chains `extends:` cross-phase. This protocol fixes the schema as a single composite contract: layout + frontmatter + artifact boundaries + engineering-guide shape are inseparable in practice because every consuming agent (epic-writer, fr-decomposer, story-writer, eng-guide-writer, validator) touches all four facets.

## Contract

### Directory layout

Under `docs/<initiative>/`, agents MUST use this layout exactly:

```
docs/<initiative>/
├── initiative.md
├── INDEX.md
└── epics/<system>/
    ├── epic.md
    ├── vocab.md
    ├── engineering_guide.md
    ├── INDEX.md
    └── phases/phase-<N>/stories/FR-<NNN>/
        ├── story.md
        ├── design.md
        ├── impl.md
        └── test.md
```

DO NOT create `phases/phase-N/notes.md`. DO NOT create epic-level `design.md`, `impl.md`, or `test.md` — model cross-cutting work as a foundational story (e.g., `FR-000`).

### FR identifier rules

- FR-NNN MUST be globally unique within an epic.
- FR-NNN MUST be monotonic. NEVER reuse a retired FR number.
- FR-NNN MUST be three digits, zero-padded.

### story.md frontmatter

Every story.md MUST declare:

```yaml
id: FR-NNN
title: <string>
phase: <integer>                # MUST equal the phase-N directory it lives in
status: skeleton | drafting | shipped | tested
modules: [<module-name>...]
touches: [<file-path>...]
touches_function: [<file-path>:<fn-name>...]
depends_on: [<FR-id>...]        # MUST be within-phase
conflicts_with: [<FR-id>...]    # MUST be within-phase
acceptance_criteria: [<string>...]
owner: <agent-id | human-id>
labels: [<label>...]
version: <integer>              # MUST equal the protocol version this story conforms to
```

DO NOT add `branch:`, `created:`, `shipped:`, `breaking_change:`, `extends:`, or `supersedes:`. Branch derives from `feature/<system>/<phase>/<fr-slug>`. Created/shipped derive from git. Use the `breaking` label instead of `breaking_change:`. Cross-phase lineage edges are forbidden.

Acceptance criteria are AUTHORITATIVE in frontmatter. The story body MUST NOT duplicate them.

### epic.md frontmatter

```yaml
name: <system-name>
type: epic | initiative
description: <one-line scope>
domain: <from SKILL_TAXONOMY domains>
version: <integer>
```

Contracts MUST live as a `## Contracts` section inside epic.md. DO NOT create a separate `contracts.md`.

### Edge semantics

- `depends_on` and `conflicts_with` MUST reference FRs within the same phase. A cross-phase reference is a protocol violation.
- `touches` is file-level granularity. `touches_function` is `path:fn` granularity.
- `extends` and `supersedes` MUST NOT be used. Cross-phase coordination flows through the regenerated engineering guide and git history.

### Subtask boundaries

- story.md MUST contain WHAT only: AC, observable behavior, edge cases as outcomes. NEVER algorithm or data-structure details.
- design.md MUST contain HOW: algorithm, data structures, internal interfaces, tradeoff rationale.
- impl.md MUST contain non-obvious implementation notes only: deviations from design, debugging discoveries, decisions under fire. NEVER mechanical change logs.
- test.md MUST contain test plan and assertion intent. NEVER runtime CI results.

### engineering_guide.md

Core sections MUST appear in this order: `Overview`, `Architecture`, `Modules`, `Contracts`, `Operations`. Optional sections (`Testing Strategy`, `Performance`, `Migration`, `Security`) MUST appear after Core when the system declares them applicable.

Frontmatter MUST include `regenerated_at: <commit-hash>`. The engineering guide MUST NOT name FRs in primary content — INDEX.md owns the FR view.

### vocab.md

Each term MUST have a structured YAML block followed by a markdown gloss. epic.md, engineering_guide.md, and stories MUST cite vocab.md terms. They MUST NOT redefine vocab terms locally.

### Forbidden sections, dependency reads, tmp-file handoff

- DO NOT add an `## Activity` section to story.md. Process exhaust lives in git log; non-obvious decisions live in impl.md.
- BEFORE opening the body of a dependency's story.md, STOP and read frontmatter only. NEVER read the body of a dependency story.
- Story-writers MUST read FR context from `.tmp/fr-context/FR-<NNN>.md`. AFTER writing the four story artifacts, the story-writer MUST delete its own tmp file.

### Version match

BEFORE writing or validating any story.md or epic.md, MUST verify the `version:` field equals the protocol version the tool or agent targets. On mismatch, MUST fail loudly per the Failure Assertion below.

## Failure Assertion

If any contract rule above is violated, STOP and output the line below, substituting the actual file path and naming the specific rule that was violated (e.g. "story body duplicates acceptance_criteria", "impl.md contains mechanical change log", "test.md contains runtime CI results", "vocab term redefined locally", "cross-phase depends_on edge", "forbidden field `branch:` present"):

`PROTOCOL FAILURE: docs-engineering-ticket-shape — <file-path>: <specific rule violated>`
