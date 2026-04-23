# Scripts Registry

Repo management scripts. Before creating a new script, check if one already covers the capability you need.

| Script | Audience | Action | Scope | Description |
|--------|----------|--------|-------|-------------|
| [cortex](../cortex) | consumer | inspect | repo | Top-level dispatcher — routes to scripts by subcommand |
| [install](../scripts/install.sh) | consumer | install | synapse | CLI entry point for installing and managing skill symlinks |
| [audit-artifacts](../scripts/audit-artifacts.sh) | maintainer | inspect | repo | Inventory and promotion-signal audit for companion artifacts |
| [check-links](../scripts/check-links.sh) | maintainer | inspect | repo | Validate relative markdown links in src/ for broken targets |
| [reorganize](../scripts/reorganize.sh) | maintainer | repair | repo | Domain-based artifact reorganization utility |
| [zip-skills](../scripts/zip-skills.ps1) | consumer | create | synapse | Package skills into distributable zip (Windows/PowerShell) |
| [scaffold](../scripts/scaffold.sh) | contributor | create | synapse | Create a new synapse with correct structure and registry entries |
| [pathway](../scripts/pathway.sh) | consumer | install | pathway | Manage pathway bundles — list, show, install, create, export |
| [validate](../scripts/validate.sh) | contributor | inspect | repo | Run structural checks without committing |
| [sync](../scripts/sync-registry.sh) | maintainer | repair | repo | Sync registries and READMEs from disk state |
