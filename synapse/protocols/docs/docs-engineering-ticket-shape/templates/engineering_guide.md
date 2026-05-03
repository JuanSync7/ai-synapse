---
name: <epic-name>-engineering-guide
type: engineering_guide
description: <one-line>
regenerated_at: <git-commit-hash>
version: 1
---

# <Epic Name> — Engineering Guide

> Regenerated from the `touches:` union of this phase's shipped stories + epic.md + vocab.md. Primary content describes the system as it stands. The FR-by-FR view lives in [INDEX.md](INDEX.md).

## Overview

<Purpose, scope boundary, system-level shape. What this epic delivers as a working system. Carry forward stable content from prior eng-guide; refresh only what this phase changed.>

## Architecture

<Components and their relationships at the architecture layer. Block-level diagrams or prose. Describe boundaries between subsystems and the contracts that cross them. NEVER name FR ids here.>

- **<Component A>** — <role, key responsibilities>
- **<Component B>** — <role>
- **Interactions:** <how A and B compose>

## Modules

<One subsection per module in the touches union for this phase. Each subsection: purpose, public surface, key invariants. Module-internal algorithms belong in the FR's design.md, not here.>

### <module-name>

<Purpose. Public surface. Key invariants the module guarantees. Reference vocab terms by name.>

### <module-name>

<repeat>

## Contracts

<Externally-visible interfaces, invariants, and error envelopes the system establishes. Pulled forward from epic.md `## Contracts` and shipped stories' contracts as flattened state. NEVER name FR ids here.>

- **<Contract name>** — <what it guarantees, who consumes it, version / stability notes>

## Operations

<Observability, deployment, runbook references. How operators interact with this system in production. Link to dashboards, runbooks, deploy docs by URL — do not embed large content.>

- **Observability:** <metrics, logs, traces — what to watch>
- **Deployment:** <how this system ships — link to deploy doc>
- **Runbook:** <link to incident response procedures>

---

<!-- Optional sections appear AFTER Operations. Omit any that don't apply. -->

## Testing Strategy

<How testing is structured at the epic level. Cross-FR test infrastructure, shared fixtures, integration harness layout. Per-FR test plans live in each FR's test.md.>

## Performance

<Performance budgets, benchmarks, capacity planning notes that span FRs.>

## Migration

<Backward compatibility, deprecation timelines, rollout phasing notes.>

## Security

<Security posture, threat model summary, audit trail notes.>

---

## Provenance

<Optional. References to FR ids that contributed to the current state. This is the ONLY section where FR ids may appear. Useful when reviewers need to trace eng-guide content back to its FR origin.>

- Last regeneration touches: FR-NNN (<title>), FR-NNN (<title>), ...

---

<!--
Template usage notes:

- Frontmatter `regenerated_at:` MUST be present and non-empty. Set to the current git commit hash.
- Frontmatter `version:` MUST equal the protocol version.

- Core sections appear in this exact order: Overview → Architecture → Modules → Contracts → Operations.
- Optional sections (Testing Strategy, Performance, Migration, Security) MUST appear AFTER Operations. NEVER interleaved.

- Primary content (body of any core section) MUST NOT contain references matching `FR-\d{3}`. The FR view lives in INDEX.md.
- FR ids MAY appear in the optional `## Provenance` section and in frontmatter only.

- Vocab terms MUST be defined in vocab.md. NEVER redefine locally. If a needed term is missing, surface as a failure rather than inventing.

- Token-budget invariant: regeneration consumes only the touches union for THIS phase, not "all stories ever." If you find yourself trying to capture cumulative history, stop — that violates the regeneration contract.

- This file is REGENERATED, not patched. Treat each regeneration as authoritative for the system's current state. Drift checks (eng-guide-reviewer) compare new vs prior to flag ambiguous removals.
-->
