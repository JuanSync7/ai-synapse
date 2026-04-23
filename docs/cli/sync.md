# cortex sync

Sync registries and READMEs from disk state -- detect and repair drift.

## Usage

```
./cortex sync [<command>]
```

## Description

Compares registry files and domain READMEs against what actually exists on disk. Detects stale entries (artifact removed but row remains), path mismatches (artifact moved but registry not updated), and missing/stale README rows. Covers skills, agents, protocols, and tools across both `src/` and `external/` directories.

## Subcommands

| Subcommand | Description |
|------------|-------------|
| `status` | Show drift between disk and registries/READMEs (default when no subcommand given) |
| `fix` | Auto-repair: remove stale entries, update mismatched paths, add missing README rows |
| `readme` | Regenerate all domain READMEs from disk state (preserves header text and post-table content) |

## Examples

```bash
./cortex sync                             # show drift (same as 'status')
./cortex sync status                      # show drift explicitly
./cortex sync fix                         # auto-repair all detected drift
./cortex sync readme                      # regenerate all domain READMEs
```

## Options

| Flag | Description |
|------|-------------|
| `-h`, `--help` | Show help message |

## Related

- [`cortex validate`](validate.md)
- [`cortex reorganize`](reorganize.md)
