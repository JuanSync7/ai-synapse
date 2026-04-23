# cortex list

List currently installed skill symlinks.

## Usage

```
./cortex list
```

## Description

Scans `~/.claude/skills/` for symlinks and prints each skill name alongside the path it points to. Useful for verifying what is currently installed and confirming symlink targets. Only shows symlinks -- regular files or directories in the skills folder are ignored.

## Examples

```bash
./cortex list
```

## Options

None.

## Related

- [`cortex available`](available.md)
- [`cortex doctor`](doctor.md)
