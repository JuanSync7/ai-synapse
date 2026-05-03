# Protocol Registry

Behavioral contracts injected into agents by consuming skills. Before creating a new protocol, check if one already covers the behavioral contract you need.

| Protocol | Description | Domain | Type | Consumers |
|----------|-------------|--------|------|-----------|
| [execution-trace](synapse/protocols/observability/execution-trace.md) | Structured self-report trace for subagent observability | observability | trace | improve-skill, auto-research |
| [failure-reporting](synapse/protocols/observability/failure-reporting.md) | Standardized failure tag format for agents and protocols | observability | schema | all agents, all protocols |
| [external-memory](synapse/protocols/memory/external-memory.md) | Behavioral contract for file-based working memory enabling state externalization | memory | contract | write-spec-docs |
| [docs-engineering-ticket-shape](synapse/protocols/docs/docs-engineering-ticket-shape/docs-engineering-ticket-shape.md) | Schema for ticket-shape engineering docs: directory layout, frontmatter, edges, eng-guide skeleton, version policy | docs | schema | docs-write-story, docs-epic-writer, docs-fr-decomposer, docs-story-writer, docs-eng-guide-writer, docs-ticket-validator |
