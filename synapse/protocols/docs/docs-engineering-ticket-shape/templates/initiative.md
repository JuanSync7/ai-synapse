---
name: <initiative-name>
type: initiative
description: <one-line scope>
domain: <from SKILL_TAXONOMY domains>
version: 1
---

# <Initiative Title>

## Goal

<1-2 sentences. The strategic outcome this initiative delivers. WHAT, never HOW.>

## Scope

<Which epics live under this initiative. Bullet list, each with a one-line scope statement. Link to epic directories.>

- [<epic-name>](epics/<epic-name>/) — <one-line scope>

## Out of Scope

<What this initiative explicitly does NOT cover. Prevents scope creep across child epics.>

- <out-of-scope item>

## Cross-Epic Vocabulary

<Terms used by 2+ epics under this initiative. Each child epic's vocab.md MAY reference these but MUST NOT redefine them. If a term is epic-local, define it in that epic's vocab.md instead.>

- See [vocab.md](vocab.md) (initiative-level vocab, optional — omit this section if no cross-epic terms exist).

## Strategic NFRs

<Cross-epic non-functional requirements. Performance budgets, security posture, observability standards that apply across all epics. Each child epic inherits these unless explicitly waived.>

- <NFR statement>

## Phasing

<How epics sequence relative to one another. Often a list of milestones with dependencies. Cross-epic dependencies live HERE, never in story-level depends_on edges.>

- Phase 1: <epic-name> — <what ships>
- Phase 2: <epic-name> — <depends on Phase 1 outputs>

---

<!--
Template usage notes:

- This file is OPTIONAL. Many initiatives are minimal — a single goal sentence + a list of child epics. Delete unused sections.
- This file is DECLARATIVE. No algorithms, no implementation choices, no FR-level acceptance criteria.
- Cross-epic lineage flows through this file + git history, not through `extends:` or `supersedes:` fields (which are forbidden by the protocol).
- An initiative-level INDEX.md (separate file) owns the FR-by-FR view across child epics. Do not list FRs here.
-->
