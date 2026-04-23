# cortex pathway

Manage pathway bundles -- curated sets of skills, agents, protocols, and tools.

## Usage

```
./cortex pathway <subcommand> [args]
```

## Description

Pathways are YAML files in `pathways/` that define named bundles of synapses for a specific harness (claude, codex, gemini, or multi). A pathway can inherit from a parent pathway, and the child's synapses are merged additively with the parent's (deduplicated). Use pathways to define team-specific or project-specific installation profiles.

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `list` | List all available pathways with their harness and description |
| `show <name>` | Show a pathway's metadata and resolved synapse list (flattens inheritance) |
| `install <name>` | Install all synapses in a pathway using the pathway's configured harness |
| `create <name>` | Create a new pathway from template in `pathways/<name>.yaml` |
| `export <name>` | Export the resolved (inheritance-flattened) pathway as YAML to stdout |

## Examples

```bash
./cortex pathway list                     # list all pathways
./cortex pathway show ml-training         # show resolved contents of a pathway
./cortex pathway install ml-training      # install all synapses in the pathway
./cortex pathway create my-team           # create a new pathway from template
./cortex pathway export my-team           # export resolved YAML to stdout
```

## Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help message |

## Related

- [`cortex install`](install.md)
- [`cortex scaffold`](scaffold.md)
