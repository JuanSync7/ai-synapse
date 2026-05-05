# Agent Taxonomy

Controlled vocabulary for agent metadata. When creating a new agent, pick `domain` and `role` from the tables below. If nothing fits, propose an addition to this file — do not invent ad hoc values.

Agents follow the `{domain}-{subdomain?}-{concern}-{role}` naming convention — lowercase-hyphenated.

- **The domain prefix clusters related agents** — all `skill-eval-*` sort together.
- **The role noun communicates what the agent *is*, not what it produces** — prefer `judge` over `generate-criteria`, `reviewer` over `produces-feedback`.

## Domains

| Domain | Description |
|--------|-------------|
| `synapse` | Framework-level agents: artifact authoring, evaluation, ecosystem maintenance |

## Subdomains

| Subdomain | Description |
|-----------|-------------|
| `skill` | Skill authoring and companion-file generation |
| `skill-eval` | Skill evaluation and quality assessment |
| `protocol` | Protocol authoring, signal-strength review, conformance testing |

## Roles

| Role | Description |
|------|-------------|
| `judge` | Impartial evaluator producing binary pass/fail criteria |
| `grader` | Impartial evaluator producing graded/scaled scores (e.g., 1–5 per dimension) with rationale; complement to `judge` for non-binary evaluation |
| `prompter` | Generates test inputs blind to implementation |
| `auditor` | Evaluates execution/workflow behavior |
| `writer` | Produces content from a brief or specification |
| `reviewer` | Validates output against input contract and quality criteria |
| `maintainer` | Enforces invariants across existing artifacts; reads current state, applies surgical edits, writes updated state. |
| `orchestrator` | Coordinator that dispatches sub-agents, aggregates their outputs, and emits a unified verdict; performs no domain judgment of its own. |

## Tags

Freeform — no controlled list. Use lowercase, hyphenated multi-word tags (e.g., `blind-generation`, `conformance-testing`).
