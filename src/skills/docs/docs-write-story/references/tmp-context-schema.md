# tmp-context-schema.md

Schema for the per-FR context handoff files that `docs-fr-decomposer` [F] writes and `docs-story-writer` [S] consumes.

Loaded at **[F]** to verify that each tmp file produced by the decomposer conforms before the FR-roster gate [G] is presented to the human. A non-conformant tmp file must not proceed — story-writers that receive an incomplete context will hallucinate to fill missing fields.

---

## Path Convention

```
.tmp/fr-context/FR-NNN.md
```

- One file per FR in the current phase's roster.
- `NNN` is three-digit, zero-padded, monotonically increasing, globally unique within the epic (across all phases and prior runs).
- The file is **deleted by the story-writer on success.** Surviving files at session resume = pending dispatch list — read them and resume [S] from where the session paused.

---

## File Structure

Each tmp file is YAML frontmatter + markdown body.

### Frontmatter fields

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | yes | `FR-NNN` — matches the filename stem |
| `title` | string | yes | Short, imperative, ≤ 8 words |
| `phase` | integer | yes | Phase number — must match the `phases/phase-N/` directory where the story will land |
| `brief` | string | yes | 1–2 sentences scoping exactly what this FR adds or changes |
| `depends_on` | list | yes (empty list ok) | FR-NNN ids this FR must not run before — **within-phase only** |
| `conflicts_with` | list | yes (empty list ok) | FR-NNN ids whose `touches:` sets overlap — **within-phase only** |
| `touches` | list | yes | File paths (relative to repo root) this FR will create or modify |
| `touches_function` | list | yes (empty list ok) | `path:fn-name` entries — function-level touch points (used for wave DAG construction) |
| `acceptance_criteria` | list | yes | Strings — go straight into `story.md` frontmatter; these are authoritative |
| `refs` | list | yes (empty list ok) | Pointers to relevant `epic.md` sections and `vocab.md` terms (e.g., `epic.md#contracts`, `vocab.md#ticket-shape`) |

### Body field

| Field | Required | Description |
|---|---|---|
| `brainstorm_slice` | yes | Verbatim section of the originating brainstorm memo that scopes this FR |

The `brainstorm_slice` is the body of the file — everything below the frontmatter close (`---`). It is **load-bearing**: without it the story-writer lacks the original intent and will invent scope to fill the gap.

---

## VERBATIM Annotation Rule

When the decomposer writes any structural block — directory trees, frontmatter fragments, schema excerpts — it MUST prefix the block with `<!-- VERBATIM -->`. Story-writers copy annotated blocks as-is; they must never compress or reword them.

**Good (verbatim-annotated directory tree):**

```markdown
<!-- VERBATIM -->
phases/phase-2/
  FR-007-add-roster-gate/
    story.md
    design.md
    impl.md
    test.md
```

**Bad (no annotation on structural block):**

```markdown
The FR will create a directory under phases/phase-2 for the roster gate story.
```

Without the annotation, a subagent may paraphrase the paths and produce a different directory structure than the protocol requires.

---

## Cross-Phase Edge Prohibition

`depends_on` and `conflicts_with` MUST only reference FR-NNN ids in the **same phase**. Cross-phase edges are a protocol violation — the wave DAG algorithm in `references/wave-dispatch.md` operates within a single phase and cannot resolve cross-phase dependencies.

**Good:**
```yaml
phase: 2
depends_on: [FR-005, FR-006]   # FR-005 and FR-006 are also phase-2 FRs
conflicts_with: [FR-008]        # FR-008 is also phase-2
```

**Bad (cross-phase reference):**
```yaml
phase: 2
depends_on: [FR-001]   # FR-001 is phase-1 — VIOLATION
```

If a cross-phase edge is found during [F] verification, reject the full tmp file batch and re-dispatch the decomposer.

---

## Verification Checklist (for [F])

Run these checks on **every** tmp file before approving the roster for [G]:

- [ ] `id` matches filename stem (`FR-NNN.md` → `id: FR-NNN`)
- [ ] `id` is three-digit, zero-padded, monotonic, globally unique within epic
- [ ] `phase` is an integer that matches an existing `phases/phase-N/` directory (or one that will be created)
- [ ] `brief` is 1–2 sentences, not a bullet list
- [ ] `depends_on` and `conflicts_with` reference only same-phase FRs
- [ ] `touches` contains at least one entry
- [ ] `acceptance_criteria` is non-empty
- [ ] `brainstorm_slice` body is non-empty — the verbatim memo section is present
- [ ] Structural blocks in the body are prefixed with `<!-- VERBATIM -->`
- [ ] No `refs` entry points outside `epic.md` or `vocab.md` (no raw URLs, no inline design prose)

Any failure is a reject-and-re-dispatch, not a silent patch.

---

## Lifecycle

```
[F] docs-fr-decomposer  →  writes  .tmp/fr-context/FR-NNN.md  (one per FR)
[G] FR-roster gate      →  human reviews roster summary (tmp files not modified)
[S] docs-story-writer   →  reads ONLY its own tmp file path + epic.md + vocab.md
                        →  deletes its tmp file on success
[RESUME]                →  surviving .tmp/fr-context/ files = pending dispatch list
```

The skill [S] node MUST pass each story-writer exactly one tmp file path. Passing the full context directory or another FR's tmp file violates the atomic-FR-context invariant.

---

## Complete Example

```
---
id: FR-007
title: Add FR-roster confirmation gate
phase: 2
brief: >
  Inserts a human-confirmation step between FR decomposition and story dispatch.
  The gate presents a roster summary and blocks until explicit approval is received.
depends_on:
  - FR-005
  - FR-006
conflicts_with:
  - FR-008
touches:
  - src/skills/docs/docs-write-story/SKILL.md
  - src/skills/docs/docs-write-story/agents/docs-fr-decomposer.md
touches_function:
  - src/skills/docs/docs-write-story/SKILL.md:node-G
acceptance_criteria:
  - The gate node presents FR count, ids, titles, and depends_on graph before waiting
  - Silence is not treated as confirmation — the skill waits for explicit human approval
  - On rejection, the skill re-dispatches docs-fr-decomposer from [F] with the rejection reason
refs:
  - epic.md#orchestration-invariants
  - vocab.md#fr-roster-gate
---

<!-- VERBATIM -->
### Brainstorm context: FR-roster confirmation gate

From memo section "Phase 2 — Safety Invariants" (2026-04-15):

> The original pipeline had no human checkpoint between decomposition and dispatch.
> In practice, a bad roster (wrong ids, wrong phase assignments, missing slices)
> silently propagated into story-writers and produced incoherent stories that
> passed structural checks but failed semantic review.
>
> The fix is a mandatory gate: after decomposition, the skill presents the full
> roster (ids, titles, phase assignments, dependency graph) and blocks until the
> human explicitly confirms or rejects. Rejection re-runs decomposition from scratch.
>
> Gate should be lightweight — if the protocol is tight, rubber-stamp.
> Surface only genuine anomalies: retired id reuse, cross-phase edges, missing slices.
```
