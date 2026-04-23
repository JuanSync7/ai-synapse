# Tool Taxonomy

Controlled vocabulary for tool metadata. When creating a new tool, pick `domain` and `action` from the tables below. If nothing fits, propose an addition to this file — do not invent ad hoc values.

Tools follow the `{domain}-{subdomain?}-{action?}-{name}` naming convention.

## Domains

| Domain | Description |
|--------|-------------|
| `testing` | Test generation, scoring, coverage analysis |
| `build` | Build configuration, artifact generation |
| `validation` | Input/output validation, schema checking |
| `analysis` | Code analysis, metric computation |
| `integration` | External service interaction tooling |
| `synapse` | Synapse ecosystem tooling — branching, registry sync, validation |

## Actions

| Action | Description |
|--------|-------------|
| `scorer` | Computes numeric scores or rankings |
| `generator` | Produces artifacts from inputs or templates |
| `validator` | Checks conformance against rules or schemas |
| `parser` | Extracts structured data from unstructured input |
| `transformer` | Converts between formats |
| `reporter` | Aggregates and formats results for consumption |
| `automator` | Runs a sequence of mechanical operations (git, file, CI) |

## Types

| Type | Description |
|------|-------------|
| `external` | Code lives elsewhere (MCP servers, CLI wrappers, npm/pip packages) |
| `internal` | Ships code — the tool IS the script or program |
| `wrapper` | Shell or Python wrapper around an external CLI |

## Tags

Freeform — no controlled list. Use lowercase, hyphenated multi-word tags (e.g., `schema-check`, `score-computation`).
