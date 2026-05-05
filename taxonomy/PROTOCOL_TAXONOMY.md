# Protocol Taxonomy

Controlled vocabulary for protocol metadata. When creating a new protocol, pick `domain` and `type` from the tables below. If nothing fits, propose an addition to this file — do not invent ad hoc values.

Protocols follow the `{domain}-{subdomain?}-{type?}-{name}` naming convention — lowercase-hyphenated, with subdomain/type included when they aid disambiguation; omit them when the parent directory and bare name already make scope clear.

- **Protocols live in subdirectories of `{synapse,src}/protocols/`** organized by taxonomy domain (e.g., `observability/`, `memory/`). The directory name groups related protocols by domain; the file name identifies the specific protocol.
- **The type slot communicates the protocol's role** — `trace`, `schema`, or `contract` — not what it carries.

## Domains

| Domain | Description |
|--------|-------------|
| `observability` | Execution traces, logging conventions, telemetry schemas |
| `memory` | Working memory patterns, state externalization, compaction safety |
| `synapse` | Synapse ecosystem conventions — contribution workflow, branching, CR lifecycle |

## Types

| Type | Description |
|------|-------------|
| `trace` | Captures execution flow and agent dispatch decisions |
| `schema` | Defines data structure conventions for inter-agent communication |
| `contract` | Behavioral contracts for state management patterns |

## Tags

Freeform — no controlled list. Use lowercase, hyphenated multi-word tags (e.g., `execution-trace`, `self-reported`).
