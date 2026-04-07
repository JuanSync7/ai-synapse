# Pipeline Contracts & Fallback Rules

Stage metadata (stage names, skill mappings, pipeline declarations, presets) is now in
`.claude/skills/SKILLS_REGISTRY.yaml`. This file contains only:
- Inter-stage artifact contracts (what each stage produces and what the next expects)
- Fallback rules for skipped stages
- Stage skip validation rules (superseded by SKILLS_REGISTRY.yaml `requires` — kept for reference)

## Inter-Stage Contracts

What each stage produces and what the next stage expects.

| Producer → Consumer | Contract |
|---------------------|----------|
| `brainstorm` → `spec` | Design sketch: goal, chosen approach, key decisions, scope boundary, component list |
| `spec` → `spec-summary` | Formal spec document path (spec-summary reads and summarizes it) |
| `spec` → `design` | Formal spec document path (design reads spec to produce task decomposition) |
| `design` → `impl` | Technical design document path (impl reads design to produce implementation steps) |
| `design` → `code` | Technical design document path (code reads design directly when `impl` is skipped — fewer implementation details, code stage must infer more) |
| `impl` → `code` | Implementation plan document path (code executes the plan) |
| `spec-summary` → `eng-guide` | Spec summary + spec document paths (docs-only template: eng-guide writes prospective guide from specification, not implemented code) |
| `code` → `eng-guide` | List of implemented source files + design doc path |
| `eng-guide` → `test-docs` | Engineering guide sections (error behavior, test guide) + Phase 0 contracts |
| `test-docs` → `tests` | Per-module test specifications. `write-module-tests` derives tests from the test-docs, not source files — deliberate isolation. |

## Fallback Rules

When a stage is skipped, the next stage receives the most recent available artifact.

**Examples:**
- `spec` skipped → `design` receives `brainstorm` sketch directly (less formal, design should note reduced input quality)
- `impl` skipped → `code` receives `design` output (fewer implementation details, code stage must infer more)

**Special case — `docs-only`:** The `eng-guide` stage normally receives implemented source files from `code`. In `docs-only` (no `code` stage), `eng-guide` receives spec/spec-summary output and writes a prospective engineering guide based on specification rather than implemented code.

## Stage Skip Validation

When `--stages` is used to override templates, the router (Steps 5–6 in SKILL.md) validates dependencies automatically using the `requires_all`/`requires_any` declarations in `SKILLS_REGISTRY.yaml`. The rules below are kept for reference:

| Stage | Requires |
|-------|----------|
| `code` | at least one of: `impl`, `design` |
| `tests` | `test-docs` |
| `test-docs` | `eng-guide` |
| `spec-summary` | `spec` |

If validation fails: report the missing dependency and ask for confirmation before proceeding.
