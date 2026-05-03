# synapse

Framework artifacts — the meta-tools that build, evaluate, and govern skills/agents/protocols. These ship with ai-synapse and are consumed as a dependency by adopter repos. Adopter content lives in [`../src/`](../src/).

## [skills/](skills/)

Framework skill domains (skill-creator, gatekeeper, brainstorm, eval generators, orchestration, routing).

| Domain | Description |
|--------|-------------|
| [agent/](skills/agent/) | Agent definition lifecycle — create and evaluate agent recipes |
| [meta/](skills/meta/) | Framework meta-utilities (skill routing) |
| [orchestration/](skills/orchestration/) | Multi-agent coordination |
| [protocol/](skills/protocol/) | Protocol development lifecycle — create and evaluate protocols |
| [skill/](skills/skill/) | Skill development lifecycle — create, evaluate, improve, certify |
| [synapse/](skills/synapse/) | Framework meta-skills spanning artifact types (consolidated creators, improvers, eval-writers) |

## [agents/](agents/)

Internal recipes dispatched by framework skills.

| Domain | Description |
|--------|-------------|
| [protocol-eval/](agents/protocol-eval/) | Agents for protocol evaluation |
| [skill/](agents/skill/) | Agents that operate on skill artifacts (e.g. companion-file writer) |
| [skill-eval/](agents/skill-eval/) | Agents for skill quality evaluation |

## [protocols/](protocols/)

Shared conventions and schemas injected into agent prompts.

| Domain | Description |
|--------|-------------|
| [memory/](protocols/memory/) | External memory conventions |
| [observability/](protocols/observability/) | Execution tracing and failure reporting |

## [tools/](tools/)

Mechanical capabilities used by framework skills.

| Domain | Description |
|--------|-------------|
| [synapse/](tools/synapse/) | Synapse-internal tooling (CR dispatcher) |

## SKILLS_REGISTRY.yaml

Pipeline routing metadata for the autonomous orchestrator. Lists pipeline-routable skills with their stage inputs/outputs and dependency edges.
