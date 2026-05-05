# Tool Taxonomy

Controlled vocabulary for tool metadata. When creating a new tool, pick `domain`, `action`, and `type` from the tables below. If nothing fits, propose an addition to this file — do not invent ad hoc values.

Tools follow the `{domain}-{subdomain?}-{action?}-{name}` naming convention — lowercase-hyphenated, with subdomain/action included when they aid disambiguation; omit them when the bare name already makes scope clear.

- **The action slot communicates what the tool *is*, not what it processes** — prefer `scorer` over `score-skills`, `validator` over `check-frontmatter`.

## Domains

| Domain | Description |
|--------|-------------|
| `synapse` | Framework-level tools: branching, registry sync, validation, ecosystem automation |

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
