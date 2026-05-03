# docs-engineering-ticket-shape

Schema protocol for ticket-shape engineering docs. Defines directory layout, frontmatter, edges, engineering-guide skeleton, and version policy. Loaded by every agent that writes or edits an engineering pipeline doc artifact.

## Files

| Protocol | Type | Description |
|----------|------|-------------|
| [docs-engineering-ticket-shape](docs-engineering-ticket-shape.md) | schema | The protocol contract — directory layout, frontmatter, edges, eng-guide skeleton, version policy |

## Templates

Output skeletons consumed by agents that write engineering pipeline artifacts. Each template encodes the protocol's frontmatter and section rules with usage notes inlined as HTML comments.

| Template | Purpose |
|----------|---------|
| [initiative.md](templates/initiative.md) | Cross-epic scope, vocabulary references, strategic NFRs, epic phasing |
| [epic.md](templates/epic.md) | Declarative epic — goal, scope boundary, system shape, cross-cutting NFRs, `## Contracts` |
| [vocab.md](templates/vocab.md) | Canonical term definitions — YAML block + markdown gloss per term |
| [story.md](templates/story.md) | Per-FR WHAT — frontmatter-authoritative AC, observable behavior, edge cases |
| [design.md](templates/design.md) | Per-FR HOW — algorithm, data structures, internal interfaces, tradeoff rationale |
| [impl.md](templates/impl.md) | Per-FR non-obvious implementation notes — deviations, debugging discoveries, decisions under fire |
| [test.md](templates/test.md) | Per-FR test plan and assertion intent (NEVER runtime CI results) |
| [engineering_guide.md](templates/engineering_guide.md) | Regenerated epic-level guide — stable skeleton (Overview / Architecture / Modules / Contracts / Operations + optionals), FR-free primary content |
