# Pathway Vocabulary

Controlled values for the `harness` frontmatter field defined in [`taxonomy/PATHWAY_TAXONOMY.md`](../taxonomy/PATHWAY_TAXONOMY.md).

These values apply to **pathways only** — they are NOT shared with skills, agents, protocols, or tools. Pathways have no slug-slot vocabulary (naming is free-form per the patterns documented in `PATHWAY_TAXONOMY.md`); the only controlled value is `harness`.

When creating a new pathway, pick `harness` from the table below. If nothing fits, propose a new row in this file in the same PR — do not invent ad hoc values.

## Harnesses

| Harness | Description |
|---------|-------------|
| `claude` | Claude Code — installs to ~/.claude/skills/ |
| `codex` | Codex CLI — installs to ~/.codex/skills/ |
| `gemini` | Gemini CLI — installs to ~/.gemini/extensions/ |
| `multi` | Installs to all supported harnesses |
