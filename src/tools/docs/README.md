# docs

Doc validation, regeneration, lineage, and forensic queries over engineering docs that conform to the `docs-engineering-ticket-shape` protocol.

## Tools

| Tool | Action | Description |
|------|--------|-------------|
| [docs-ticket-validator](docs-ticket-validator/) | validator | Validates a ticket-shape engineering doc set against the protocol — directory layout, frontmatter, edges, subtask boundaries, eng-guide skeleton, version policy |
| [docs-index-builder](docs-index-builder/) | generator | Regenerates INDEX.md for an epic — the FR-by-FR roster, dependency graph, and status roll-up that engineering_guide.md is forbidden to contain |
