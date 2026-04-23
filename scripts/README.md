# scripts

Repo management scripts for installing skills, managing symlinks, and packaging distributions. All scripts are routed through the top-level [`cortex`](../cortex) dispatcher — run `./cortex help` for the full command reference.

## Files

| File | Description |
|------|-------------|
| [install.sh](install.sh) | CLI entry point for installing/managing skill symlinks across harnesses |
| [audit-artifacts.sh](audit-artifacts.sh) | Inventory and promotion-signal audit for companion artifacts (agents, tools, protocols inside skill dirs) |
| [check-links.sh](check-links.sh) | Validates relative markdown links in `src/` for broken targets |
| [reorganize.sh](reorganize.sh) | Domain-based artifact reorganization utility |
| [zip-skills.ps1](zip-skills.ps1) | PowerShell script for packaging skills into a distributable zip (Windows) |
| [pathway.sh](pathway.sh) | Manage pathway bundles — list, show, install, create, export |
| [validate.sh](validate.sh) | Run structural checks without committing |
| [sync-registry.sh](sync-registry.sh) | Sync registries and READMEs from disk state — detect and fix drift |

## lib/

Sourced by `install.sh` — not executable directly.

| File | Description |
|------|-------------|
| [lib/common.sh](lib/common.sh) | Shared variables, `usage()`, and `_install_skills_to()` utility |
| [lib/commands-skills.sh](lib/commands-skills.sh) | Skill installation and packaging commands (Claude, Codex, Gemini, zip) |
| [lib/commands-manage.sh](lib/commands-manage.sh) | Listing, cleanup, agents, identity, and diagnostics commands |
