# Skill Taxonomy

Controlled vocabulary for skill metadata. When creating a new skill, pick `domain` and `intent` from the tables below. If nothing fits, propose an addition to this file — do not invent ad hoc values.

## Domains

| Domain | Description |
|--------|-------------|
| `docs` | Documentation authoring |
| `docs.scope` | Scope definition and phase planning |
| `docs.arch` | System-level architecture decisions |
| `docs.spec` | Specs and summaries |
| `docs.design` | Design documents |
| `docs.impl` | Implementation reference docs |
| `docs.post-build` | Engineering guides, test docs |
| `code` | Code generation and execution |
| `code.test` | Test code authoring and execution |
| `code.plan` | Execution planning |
| `skill` | Skill development lifecycle |
| `skill.eval` | Skill evaluation and certification |
| `skill.create` | Skill creation and improvement |
| `meta` | Meta-level tools: routing, framework utilities |
| `optimization` | Autonomous iterative improvement |
| `orchestration` | Multi-agent coordination |
| `creative` | Standalone creative/visual |
| `integration` | External tool integrations |
| `agent` | Agent development lifecycle |
| `agent.create` | Agent creation and improvement |
| `agent.eval` | Agent evaluation and certification |
| `protocol` | Protocol development lifecycle |
| `protocol.create` | Protocol creation and improvement |
| `protocol.eval` | Protocol evaluation and certification |
| `integration` | External tool integrations |
| `integration.jira` | JIRA project tracking |
| `frameworks.langgraph` | LangGraph-specific tools |

## Intents

| Intent | Description |
|--------|-------------|
| `write` | Produce a new artifact |
| `review` | Evaluate/critique existing work |
| `plan` | Create an execution strategy |
| `route` | Dispatch to another skill |
| `execute` | Run/dispatch agents |
| `improve` | Iterate on existing artifact |
| `debug` | Diagnose and fix issues |
| `analyze` | Extract insights without changing anything |
| `convert` | Transform between formats |
| `validate` | Check correctness against a reference |
| `summarize` | Condense existing artifact |
| `migrate` | Move between versions/platforms |
| `generate` | Produce from template/config |

## Tags

Freeform — no controlled list. Use lowercase, hyphenated multi-word tags (e.g., `test-planning`, `source-of-truth`).
