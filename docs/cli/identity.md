# cortex identity

Install identity files to Claude Code.

## Usage

```
./cortex identity
```

## Description

Creates symlinks from `~/.claude/` to identity files in the repo's `identity/` directory. Installs `SOUL.md` and `STAKEHOLDER.md` (as `stakeholder.md`). If a target file already exists as a regular file (not a symlink), a warning is printed and the file is not overwritten -- you must back up and remove it manually first. The template file `SOUL.template.md` is not installed.

## Examples

```bash
./cortex identity
```

## Options

None.

## Related

- [`cortex agents`](agents.md)
- [`cortex install`](install.md)
