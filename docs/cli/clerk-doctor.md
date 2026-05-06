# cortex clerk doctor

Clerk-specific self checks. **This is not a full `cortex doctor` scan** — it only validates clerk's preconditions.

## Usage

```
cortex clerk doctor [--state <path>]
```

## Checks

1. **State file parses.** `~/.synapse/clerk_state.toml` is well-formed and `schema_version == 1` (or absent — clerk creates it on first run).
2. **`gh auth status`.** Reports whether the GitHub CLI is authenticated. Without auth, `bump-externals --apply` will refuse.
3. **`.gitmodules` presence.** Lists every `external/<suite>` submodule and whether clerk has ever observed it (first-seen tag) or bumped it.

Doctor exits 0 unless the state file is malformed (exit 1). A missing state file or absent `gh` auth produces warnings, not errors — clerk degrades gracefully on a fresh machine.

## Difference from `cortex doctor`

| | `cortex doctor` | `cortex clerk doctor` |
|---|---|---|
| Scope | Installed artifacts on this machine | Clerk's own preconditions |
| Reads | `installed.lock`, `pins.toml` | `clerk_state.toml`, `.gitmodules` |
| Findings | 7 categories (drift, missing-source, etc.) | 3 self checks |

Run both in CI for full coverage.
