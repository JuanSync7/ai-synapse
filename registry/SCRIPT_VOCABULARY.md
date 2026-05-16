# Script Vocabulary

Controlled values for the `audience`, `action`, and `scope` comment-frontmatter fields defined in [`taxonomy/SCRIPT_TAXONOMY.md`](../taxonomy/SCRIPT_TAXONOMY.md).

These values apply to **scripts only** — they are NOT shared with skills, agents, protocols, tools, or pathways. Scripts have no slug pattern; the controlled values live in the `# @audience:` / `# @action:` / `# @scope:` comment header at the top of each `scripts/*.sh` file.

When creating a new script, pick values from the tables below. If nothing fits, propose a new row in this file in the same PR — do not invent ad hoc values. `scripts/validate.sh` reads this file at validation time.

## Audiences

| Audience | Description |
|----------|-------------|
| `consumer` | End users loading synapses into their environment |
| `contributor` | People creating or modifying artifacts |
| `maintainer` | Repo hygiene, drift detection, structural repair |
| `automation` | CI/CD pipelines and scheduled jobs (reserved) |

## Actions

| Action | Description |
|--------|-------------|
| `install` | Put synapses into a harness or environment |
| `create` | Scaffold new artifacts or pathways |
| `inspect` | Read-only analysis — list, validate, audit, doctor |
| `repair` | Write operations that fix drift or clean state |

## Scopes

| Scope | Description |
|-------|-------------|
| `synapse` | Individual artifacts (skills, agents, protocols, tools) |
| `pathway` | Named bundles of synapses |
| `repo` | Repository structure (registries, READMEs, taxonomies) |
| `harness` | Installed symlinks in target environment (claude, codex, gemini) |
| `identity` | Identity files (SOUL.md, STAKEHOLDER.md) |
