# cortex audit

Companion artifact inventory and promotion-signal audit.

## Usage

```
./cortex audit [<command>]
```

## Description

Scans skill directories (both `src/skills/` and `external/`) for companion artifacts -- agents, tools, and protocols that live inside skill `agents/`, `tools/`, or `protocols/` subdirectories. Identifies which are symlinks vs. regular files, detects copies that should be symlinks to promoted versions in `src/agents/` or `src/protocols/`, and flags duplicates that appear across multiple skills as promotion candidates.

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `inventory` | List all companion artifacts, showing whether each is a symlink or a file |
| `signals` | Show promotion signals: copies that should be symlinks, and duplicate names across skills |
| `fix` | Auto-convert identical copies to symlinks; flag copies that have drifted from the promoted version |
| *(none)* | Full audit: runs `inventory` followed by `signals` |

## Examples

```bash
./cortex audit                            # full audit (inventory + signals)
./cortex audit inventory                  # list all companion artifacts
./cortex audit signals                    # show promotion signals only
./cortex audit fix                        # convert identical copies to symlinks
```

## Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help message |

## Related

- [`cortex sync`](sync.md)
- [`cortex doctor`](doctor.md)
