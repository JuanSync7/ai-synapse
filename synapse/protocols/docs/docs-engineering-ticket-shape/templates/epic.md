---
name: <system-name>
type: epic
description: <one-line scope>
domain: <from SKILL_TAXONOMY domains>
version: 1
---

# <Epic Title>

## Goal

<1-2 sentences. The observable outcome this epic delivers. WHAT, not HOW.>

## Scope Boundary

<What this epic includes / what it explicitly excludes. Boundary lines prevent scope drift during FR decomposition.>

**In scope:**
- <inclusion>

**Out of scope:**
- <exclusion> — handled by <other epic | future phase>

## System Shape

<High-level component map. Architecture-layer description only — no algorithms, no data structures, no internal interfaces. Name modules and their relationships; details belong in design.md per FR.>

- <Component A> — <one-line role>
- <Component B> — <one-line role>

## Cross-Cutting NFRs

<Performance budgets, security posture, observability requirements that apply to every FR in this epic. Each FR's design.md inherits these.>

- <NFR statement with measurable threshold>

## Contracts

<Externally-visible interfaces this epic establishes — API surfaces, event envelopes, error shapes, configuration contracts. Declarative form. Detailed schemas/algorithms belong in the consuming FR's design.md.>

- <Contract name> — <what it guarantees, who consumes it>

## Phasing

<Phases within this epic. Each phase is a coherent shippable slice. FR-level depends_on edges MUST stay within-phase.>

- Phase 1: <slice description>
- Phase 2: <slice description, depends on Phase 1 outputs>

## Foundational Stories

<If cross-cutting work requires HOW-level coordination — shared error envelope, shared client SDK, observability harness — model it as a foundational story (e.g., FR-000-shared-error-envelope). DO NOT inline implementation here.>

- <FR-NNN | shorthand> — <one-line role>

---

<!--
Template usage notes:

- Strict declarative discipline. NEVER include algorithms, data-structure schemas, named API endpoints with implementation detail, FR-level acceptance criteria, or specific implementation choices (library names, framework versions).
- Cross-cutting work that requires HOW = a foundational FR-NNN story. Not an inline section here.
- The `## Contracts` section MUST live in epic.md (this file). DO NOT create a separate `contracts.md`.
- Acceptance criteria belong in story.md frontmatter, not here.
- Vocabulary references link to vocab.md; never redefine terms here.
- Frontmatter `version:` MUST equal the protocol version. Mismatch is a hard failure.
-->
