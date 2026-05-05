# Skill Taxonomy

Controlled vocabulary for skill metadata. When creating a new skill, pick `domain` and `intent` from the tables below. If nothing fits, propose an addition to this file — do not invent ad hoc values.

Skills follow the `{domain}-{subdomain?}-{intent?}-{name}` naming convention — lowercase-hyphenated, with subdomain/intent included when they aid disambiguation; omit them when the bare name already makes scope clear.

- **Globally unique** — skill names resolve from a flat `~/.claude/skills/` directory; no runtime namespacing exists. `scripts/install.sh` warns on collisions at install time; never rely on last-write-wins — rename before promoting.
- **The intent slot communicates what the skill *does*, not what it produces** — prefer `write` over `produces-spec`, `improve` over `quality-loop`.

## Domains

| Domain | Description |
|--------|-------------|
| `agent` | Agent development lifecycle |
| `agent.create` | Agent creation and improvement |
| `agent.eval` | Agent evaluation and certification |
| `code` | Code generation and execution |
| `code.plan` | Execution planning |
| `code.test` | Test code authoring and execution |
| `creative` | Standalone creative/visual |
| `docs` | Documentation authoring |
| `docs.arch` | System-level architecture decisions |
| `docs.design` | Design documents |
| `docs.impl` | Implementation reference docs |
| `docs.post-build` | Engineering guides, test docs |
| `docs.scope` | Scope definition and phase planning |
| `docs.spec` | Specs and summaries |
| `frameworks` | Framework-specific tooling |
| `frameworks.langgraph` | LangGraph-specific tools |
| `integration` | External tool integrations |
| `integration.jira` | JIRA project tracking |
| `meta` | Meta-level tools: routing, framework utilities |
| `optimization` | Autonomous iterative improvement |
| `orchestration` | Multi-agent coordination |
| `protocol` | Protocol development lifecycle |
| `protocol.create` | Protocol creation and improvement |
| `protocol.eval` | Protocol evaluation and certification |
| `skill` | Skill development lifecycle |
| `skill.create` | Skill creation and improvement |
| `skill.eval` | Skill evaluation and certification |
| `synapse` | Synapse ecosystem management — branching, registry, validation |

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
