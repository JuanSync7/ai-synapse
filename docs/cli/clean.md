# cortex clean

Remove all installed symlinks across all harnesses.

## Usage

```
./cortex clean
```

## Description

Removes all symlinks that point into the ai-synapse repo from every harness target directory. Covers Claude Code skills (`~/.claude/skills/`), agents (`~/.claude/agents/`), Codex CLI skills (`~/.codex/skills/`), Gemini CLI skills (`~/.gemini/extensions/ai-synapse/skills/`), and identity files (`~/.claude/SOUL.md`, `~/.claude/stakeholder.md`). Also removes the Gemini extension manifest and cleans up empty directories if no skills remain. Dangling symlinks (targets that no longer exist) are also removed.

## Examples

```bash
./cortex clean
```

## Options

None.

## Related

- [`cortex install`](install.md)
- [`cortex doctor`](doctor.md)
