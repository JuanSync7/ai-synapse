---
name: docs-ticket-validator
description: Validates a ticket-shape engineering doc set against the docs-engineering-ticket-shape protocol — directory layout, frontmatter, edge rules, subtask boundaries, eng-guide skeleton, version policy
domain: docs
action: validator
type: internal
tags: [ticket-shape, schema-check, frontmatter, edge-validation, protocol-conformance]
---

# Docs Ticket Validator

Mechanical validator that checks a ticket-shape engineering doc set for conformance to `synapse/protocols/docs/docs-engineering-ticket-shape/docs-engineering-ticket-shape.md`. Runs as a deterministic script — no LLM, no judgment. Pre-commit and CI consumer; also used by `/docs-write-story` after a wave completes to verify writer output before advancing to the eng-guide regen.

## When to use

- After `/docs-write-story` ships a phase — verify all written artifacts conform before regenerating the engineering guide.
- In pre-commit hook — catch frontmatter / layout / edge violations before they land.
- In CI — gate merges on conformance to the protocol contract.
- Standalone forensic check — point at any epic directory and get a structured report.

## Input

```bash
docs-ticket-validator.sh <epic-dir> [--fail-fast] [--format json|text]
```

| Arg | Required | Description |
|-----|----------|-------------|
| `<epic-dir>` | yes | Path to an epic directory (e.g., `docs/<initiative>/epics/<epic>/`) |
| `--fail-fast` | no | Exit on first violation rather than collecting all |
| `--format` | no | Output format — `text` (default, human) or `json` (machine) |

## Output

- Exit code: `0` on full conformance, `1` on any violation, `2` on tool error (missing path, malformed YAML, etc.)
- stdout: violation list (text or JSON)

JSON shape:
```json
{
  "epic_dir": "docs/.../epics/<epic>/",
  "protocol_version": 1,
  "checks_run": 13,
  "violations": [
    {
      "rule": "<rule-id>",
      "severity": "block",
      "path": "<file-path>",
      "detail": "<specific reason>"
    }
  ]
}
```

Text format prints the same data as `PROTOCOL FAILURE: docs-engineering-ticket-shape — <path>: <rule>` lines, matching the protocol's failure assertion format.

## Validation rules

The validator runs every rule below on every file in scope. Rules trace 1:1 to the protocol contract.

### Directory layout

- **L01:** Epic directory contains exactly `epic.md`, `vocab.md`, `engineering_guide.md`, `INDEX.md` (and optional `phases/` tree). No `design.md`, `impl.md`, `test.md`, `contracts.md` at epic level.
- **L02:** Each FR directory at `phases/phase-<N>/stories/FR-NNN/` contains exactly `story.md`, `design.md`, `impl.md`, `test.md`. No extras.
- **L03:** `phase-<N>` integer in path matches `phase:` field in every story.md it contains.
- **L04:** No `phases/phase-N/notes.md` or other forbidden phase-level files.

### FR identifiers

- **F01:** Every FR-NNN id is three-digit zero-padded.
- **F02:** No id appears twice (across directory names, story.md `id:` fields, and meta.yaml roster).
- **F03:** FR ids are monotonic — no retired-number reuse within the epic.

### story.md frontmatter

- **S01:** All required fields present: `id`, `title`, `phase`, `status`, `modules`, `touches`, `touches_function`, `depends_on`, `conflicts_with`, `acceptance_criteria`, `owner`, `labels`, `version`.
- **S02:** No forbidden fields: `branch:`, `created:`, `shipped:`, `breaking_change:`, `extends:`, `supersedes:`.
- **S03:** `version:` equals the protocol version.
- **S04:** `phase:` equals the integer in the directory path.

### Edges

- **E01:** Every entry in `depends_on` references an FR whose `phase:` equals the referencing FR's `phase:`.
- **E02:** Every entry in `conflicts_with` references an FR whose `phase:` equals the referencing FR's `phase:`.
- **E03:** `touches` is file-level (`<path>`); `touches_function` is `<path>:<fn>` form.

### Subtask boundaries

- **B01:** story.md body MUST NOT contain `## Activity` or other forbidden sections.
- **B02:** story.md body MUST NOT duplicate AC from frontmatter (string-similarity check against AC list).
- **B03:** impl.md MUST NOT contain mechanical change-log markers (e.g., bullet sequences starting with "added", "renamed", "moved" in succession).
- **B04:** test.md MUST NOT contain runtime CI result markers (e.g., "PASS", "FAIL", coverage percentages, last-run timestamps).

### epic.md

- **EP01:** Required frontmatter fields: `name`, `type`, `description`, `domain`, `version`.
- **EP02:** `version:` equals the protocol version.
- **EP03:** Has a `## Contracts` section if any externally-visible contracts are declared (heuristic: contract terms in vocab.md cross-referenced).

### vocab.md

- **V01:** Each term has a YAML block (validator-readable) followed by a markdown gloss.
- **V02:** No vocab term is redefined locally in epic.md, engineering_guide.md, or any story.md (string-match check on term names + definition prose).

### engineering_guide.md

- **G01:** Frontmatter contains `regenerated_at:` with a non-empty value.
- **G02:** `version:` equals the protocol version.
- **G03:** Core sections (`Overview`, `Architecture`, `Modules`, `Contracts`, `Operations`) appear in this exact order.
- **G04:** Optional sections (if present) appear AFTER `Operations`, never interleaved.
- **G05:** Primary content (body of any core section) contains zero matches of `FR-\d{3}`. Provenance section (after Operations) and frontmatter are exempt.

## How it works

1. Locate `docs-engineering-ticket-shape.md` (search up the tree for `synapse/protocols/docs/docs-engineering-ticket-shape/`)
2. Parse the protocol version from its frontmatter
3. Walk `<epic-dir>` recursively, parsing every `.md` file's frontmatter and body
4. Apply each rule above; collect violations with file path + rule id + detail
5. If `--fail-fast`, exit 1 on first violation; otherwise collect all
6. Emit report in requested format and exit with the appropriate code

## Implementation

`docs-ticket-validator.sh` — bash + a YAML parser (yq) + grep / sed for body-content checks. Pure mechanical — never invokes an LLM. Designed to run in <2s on a typical epic directory.

## Out of scope

- Quality judgment (is the AC list good?) — that's `/improve-skill`'s territory, not this tool.
- Writing or fixing violations — this tool reports only. Fixes flow back through `docs-write-story` or manual edits.
- Cross-epic rules — this tool validates one epic at a time.
- Index regeneration — see sibling tool `docs-index-builder`.

## Failure handling

If the tool itself errors (missing protocol file, malformed YAML, unreadable directory), it exits with code `2` and prints a `TOOL FAILURE:` line. Violations of the protocol are exit code `1` — distinct from tool errors so CI can route them differently.
