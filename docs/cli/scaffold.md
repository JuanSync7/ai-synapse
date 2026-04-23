# cortex scaffold

Create a new synapse with correct structure, frontmatter, and registry entries.

## Usage

```
./cortex scaffold <type> <domain> <name>
```

## Description

Generates the boilerplate for a new artifact. Creates the file(s) with correct YAML frontmatter, adds a row to the domain README, and adds a registry entry. The domain is validated against the relevant taxonomy file before anything is created -- if the domain does not exist in the taxonomy, the command fails with a suggestion to add it there first. Refuses to overwrite existing artifacts.

## Types

| Type | Creates |
|------|---------|
| `skill` | `src/skills/<domain>/<name>/SKILL.md` + `EVAL.md` |
| `agent` | `src/agents/<domain>/<name>.md` |
| `protocol` | `src/protocols/<domain>/<name>.md` |
| `tool` | `src/tools/<domain>/<name>/TOOL.md` |

## Examples

```bash
./cortex scaffold skill docs my-new-skill              # creates skill skeleton
./cortex scaffold agent ml training-monitor             # creates agent definition
./cortex scaffold protocol observability my-protocol    # creates protocol definition
./cortex scaffold tool integration jira-mcp             # creates tool skeleton
```

## Options

| Argument | Description |
|----------|-------------|
| `<type>` | One of: `skill`, `agent`, `protocol`, `tool` |
| `<domain>` | Domain value from the relevant taxonomy (e.g., `docs`, `ml`, `observability`) |
| `<name>` | Artifact name (must be globally unique for skills) |

## Related

- [`cortex validate`](validate.md)
- [`cortex pathway`](pathway.md)
