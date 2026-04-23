# cortex reorganize

Domain-based artifact reorganization utility.

## Usage

```
./cortex reorganize <command> [args...]
```

## Description

Uses frontmatter `domain` as the source of truth for directory placement. Skills use dot notation (`docs.spec` maps to the `docs` top-level directory). When a domain directory gets crowded, `split` moves artifacts into subdomain subdirectories at a specified dot-depth. `merge` flattens them back. After any move, the command automatically updates domain READMEs, parent READMEs, registry paths, and symlinks in skill directories.

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status [type]` | Show current vs. expected placement for all artifacts (or filter by `skills`, `agents`, `protocols`) |
| `validate [type]` | Exit 1 if any artifact is in the wrong directory based on its domain |
| `plan <type> <domain> <depth>` | Dry-run of a split -- shows what would move without changing anything |
| `split <type> <domain> <depth>` | Move artifacts into subdomain directories at the given dot-depth |
| `merge <type> <domain>` | Flatten subdomain directories back into the top-level domain directory |

## Examples

```bash
./cortex reorganize status                              # all artifact types
./cortex reorganize status protocols                    # protocols only
./cortex reorganize validate                            # check everything, exit 1 if misplaced
./cortex reorganize plan protocols frontend 2           # preview a split
./cortex reorganize split protocols frontend 2          # execute the split
./cortex reorganize merge protocols frontend            # flatten back to top-level
```

## Options

| Argument | Description |
|----------|-------------|
| `<type>` | One of: `skills`, `agents`, `protocols` |
| `<domain>` | Top-level domain name (e.g., `frontend`, `integration`) |
| `<depth>` | Dot-depth for splitting (e.g., `2` splits `frontend.api` into `frontend/api/`) |

## Related

- [`cortex sync`](sync.md)
- [`cortex validate`](validate.md)
