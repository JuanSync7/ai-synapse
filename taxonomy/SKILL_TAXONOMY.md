# Skill Taxonomy

Controlled vocabulary for skill metadata. When creating a new skill, pick `domain` and `intent` from the tables below. If nothing fits, propose an addition to this file — do not invent ad hoc values.

Skills follow the `{domain}-{subdomain?}-{intent?}-{name}` naming convention — lowercase-hyphenated, with subdomain/intent included when they aid disambiguation; omit them when the bare name already makes scope clear.

- **Globally unique** — skill names resolve from a flat `~/.claude/skills/` directory; no runtime namespacing exists. `scripts/install.sh` warns on collisions at install time; never rely on last-write-wins — rename before promoting.
- **The intent slot communicates what the skill *does*, not what it produces** — prefer `write` over `produces-spec`, `improve` over `quality-loop`.

## Domains

| Domain | Description |
|--------|-------------|
| `synapse` | Framework-level skills: artifact authoring, evaluation, orchestration, ecosystem management |

## Subdomains

| Subdomain | Description |
|-----------|-------------|
| `agent` | Agent development lifecycle (creation, evaluation) |
| `skill` | Skill development lifecycle (creation, evaluation, improvement) |
| `protocol` | Protocol development lifecycle (creation, evaluation) |
| `tool` | Tool development lifecycle (creation, evaluation) |
| `meta` | Routing and framework utilities |
| `orchestration` | Multi-agent coordination and pipeline execution |

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
