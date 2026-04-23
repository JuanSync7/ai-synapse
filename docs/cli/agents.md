# cortex agents

Install agent definitions to Claude Code.

## Usage

```
./cortex agents
```

## Description

Creates symlinks from `~/.claude/agents/` to every `.md` file in `src/agents/`. No arguments are accepted -- all agent definitions are installed. Existing symlinks pointing to the same target are skipped, and broken symlinks are repaired. The target directory can be overridden via the `CLAUDE_AGENTS_DIR` environment variable.

## Examples

```bash
./cortex agents
```

## Options

None. Installs all agents.

## Related

- [`cortex install`](install.md)
- [`cortex identity`](identity.md)
