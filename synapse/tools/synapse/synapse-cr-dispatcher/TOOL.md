---
name: synapse-cr-dispatcher
description: Creates per-artifact feature branches from change requests placed by synapse-brainstorm
domain: synapse
action: automator
type: internal
tags: [branching, change-request, workflow, git]
---

# Synapse CR Dispatcher

Mechanical tool that scans for change request files placed by `/synapse-brainstorm`'s memo-producer, then creates per-artifact feature branches following the `feature/<synapse>/<artifact-name>/<cr-slug>` convention.

## When to use

Called automatically by `/synapse-brainstorm` at the [END] phase after memo-producer has placed CR files into artifact `change_requests/` directories. Can also be called standalone to create branches from existing CR files.

## Input

```bash
synapse-cr-dispatcher.sh --date YYYY-MM-DD --slug <session-slug> [--design <path-to-design-doc>]
```

| Arg | Required | Description |
|-----|----------|-------------|
| `--date` | yes | Session date — used to match CR files |
| `--slug` | yes | Session slug — used to match CR files and derive branch names |
| `--design` | no | Path to design doc — copied alongside each CR if provided |

## Output

For each matched CR file:
- A feature branch `feature/<synapse>/<artifact-name>/<cr-slug>` created from `develop`
- The CR file + design doc (if provided) committed on that branch
- Branch pushed to remote

Prints summary of branches created, skipped, and push status.

## How it works

1. Captures current branch name (for return)
2. Stashes dirty working tree (if any)
3. Scans repo for `change_requests/*<date>*<slug>*.md` files
4. For each matched CR:
   a. Parses artifact type from CR header (`Artifact type: <skill|tool|agent|protocol>`)
   b. Derives artifact name from parent directory
   c. Extracts cr-slug from filename
   d. Checks if branch already exists — warns and skips if so
   e. Creates branch from `develop`
   f. Copies design doc into same `change_requests/` folder if provided
   g. Commits CR + design
   h. Pushes to remote
   i. Returns to develop
5. Returns to original branch
6. Pops stash
7. Prints summary

## Branch naming

```
feature/<synapse>/<artifact-name>/<cr-slug>
```

- `<synapse>`: skill | agent | protocol | tool
- `<artifact-name>`: directory name of the artifact
- `<cr-slug>`: extracted from CR filename after date and username

## CR file matching

Expects filenames following memo-producer convention: `YYYY-MM-DD-<username>-<slug>.md`

The tool matches on date + slug, ignoring username — this ensures it finds all CRs from a session regardless of who authored them.
