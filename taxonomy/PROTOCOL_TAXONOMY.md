# Protocol Taxonomy

Controlled vocabulary for protocol metadata. When creating a new protocol, pick `domain` and `type` from the tables below. If nothing fits, propose an addition to this file — do not invent ad hoc values.

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
