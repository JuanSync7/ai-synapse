# cortex check-links

Validate relative markdown links in src/ for broken targets.

## Usage

```
./cortex check-links
```

## Description

Scans all `.md` files under `src/skills/`, `src/agents/`, and `src/protocols/` for relative markdown links and verifies that each link target exists on disk. HTTP/HTTPS links and links containing template syntax (`{`, `<`) are skipped. Fragment-only anchors (`#section`) are stripped before resolution. Exits with code 1 if any broken links are found.

## Examples

```bash
./cortex check-links
```

## Options

None.

## Related

- [`cortex validate`](validate.md)
- [`cortex sync`](sync.md)
