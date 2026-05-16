# Script Taxonomy

Comment-frontmatter contract for scripts. The controlled vocabulary for `audience`, `action`, and `scope` lives in [`registry/SCRIPT_VOCABULARY.md`](../registry/SCRIPT_VOCABULARY.md). The inventory of scripts currently in the repo lives in [`registry/SCRIPT_REGISTRY.md`](../registry/SCRIPT_REGISTRY.md). This file defines the *shape*; vocabulary holds the *values*; registry holds the *inventory*.

Scripts have no slug pattern and no YAML frontmatter — they carry their metadata as bash comments at the top of each `scripts/*.sh` file.

## Comment frontmatter

Every script under `scripts/` must declare the following comment-based fields near the top of the file. `scripts/validate.sh` parses these comments and rejects scripts that omit any required field or use a value not listed in `registry/SCRIPT_VOCABULARY.md`.

```bash
#!/usr/bin/env bash
# @name: <script-name>
# @description: <one-line description of what the script does>
# @audience: <value>     # must be a row in registry/SCRIPT_VOCABULARY.md → ## Audiences
# @action: <value>       # must be a row in registry/SCRIPT_VOCABULARY.md → ## Actions
# @scope: <value>        # must be a row in registry/SCRIPT_VOCABULARY.md → ## Scopes
```

All five fields are required. `@name` should match the filename (without `.sh`).

## Tags

Freeform — no controlled list. Use lowercase, hyphenated multi-word tags.
