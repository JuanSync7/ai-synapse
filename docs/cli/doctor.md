# cortex doctor

Check for broken symlinks across all harnesses.

## Usage

```
./cortex doctor
```

## Description

Scans symlink directories for all supported harnesses and reports any broken symlinks (links whose targets no longer exist). Checks Claude Code skills (`~/.claude/skills/`), agents (`~/.claude/agents/`), Codex CLI skills (`~/.codex/skills/`), and Gemini CLI skills (`~/.gemini/extensions/ai-synapse/skills/`). If broken links are found, suggests running `cortex install all` to repair or `cortex clean` to remove all symlinks.

## Examples

```bash
./cortex doctor
```

## Options

None.

## Related

- [`cortex clean`](clean.md)
- [`cortex list`](list.md)
