# src

Source artifacts for AI-Synapse. Four artifact types live here:

## [skills/](skills/)

User-invocable recipes organized by domain. Each domain has its own README with a skill catalog.

| Domain | Description |
|--------|-------------|
| [agent/](skills/agent/) | Agent definition lifecycle — create and evaluate agent recipes |
| [code/](skills/code/) | Code generation and testing |
| [creative/](skills/creative/) | Visual and interactive output |
| [docs/](skills/docs/) | Documentation authoring pipeline |
| [frameworks/](skills/frameworks/) | Technology-specific skills |
| [integration/](skills/integration/) | External service integrations (submoduled suites) |
| [meta/](skills/meta/) | Framework utilities and routing |
| [optimization/](skills/optimization/) | Iterative improvement loops |
| [orchestration/](skills/orchestration/) | Multi-agent coordination |
| [protocol/](skills/protocol/) | Protocol development lifecycle — create and evaluate protocols |
| [skill/](skills/skill/) | Skill development lifecycle — create, evaluate, improve, certify |

## [agents/](agents/)

Internal recipes dispatched by skills — not user-invocable. Organized by domain.

| Domain | Description |
|--------|-------------|
| [docs/](agents/docs/) | Agents for documentation review and writing |
| [protocol-eval/](agents/protocol-eval/) | Agents for protocol evaluation |
| [skill-eval/](agents/skill-eval/) | Agents for skill quality evaluation |

## [protocols/](protocols/)

Shared conventions and schemas injected into agent prompts by observers.

| Domain | Description |
|--------|-------------|
| [memory/](protocols/memory/) | External memory conventions |
| [observability/](protocols/observability/) | Execution tracing and failure reporting |

## [tools/](tools/)

Mechanical capabilities — scripts, MCP servers, CLI wrappers, and external integrations. Organized by domain.

| Domain | Description |
|--------|-------------|

(no tool domains yet)
