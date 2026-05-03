# Wave Dispatch Algorithm

Reference for node [S] — Story dispatch (parallel waves). The skill builds a DAG from the FR roster and orchestrates `docs-story-writer` in waves. Wave logic MUST NOT be delegated to a subagent.

---

## Inputs

Each FR in the roster carries these edge fields (populated by `docs-fr-decomposer`):

| Field | Type | Meaning |
|-------|------|---------|
| `depends_on` | `FR-id[]` | Hard ordering — predecessor story must finish before this FR starts |
| `conflicts_with` | `FR-id[]` | Soft serialization — same-function touches; cannot share a wave |
| `touches` | `path[]` | Files this FR modifies — informational for merge-resolver, not a wave constraint |
| `touches_function` | `"path:fn"[]` | Function-level touches — used for conflict detection (same entry = conflict) |

All edges are within-phase only. Cross-phase edges are a protocol violation caught at [F].

---

## DAG Construction

Two edge classes drive the DAG:

**Hard edges (depends_on)**
- Directed. FR-A → FR-B means FR-A must be fully shipped before FR-B is dispatched.
- These determine wave ordering through topological sort.

**Soft conflict edges**
- Two FRs share a soft conflict if either:
  - FR-A lists FR-B in `conflicts_with` (or vice versa), OR
  - FR-A and FR-B share one or more identical entries in `touches_function`.
- Soft conflicts constrain wave packing: conflicting FRs cannot occupy the same wave. Their relative order is free — pick whichever serialization keeps waves widest.

**touches overlap (file-level)** is not a wave constraint. Two FRs touching the same file may run in the same wave. The merge-resolver handles output reconciliation after the wave.

---

## Wave Assignment Algorithm

```
resolved = {}          # set of shipped FR ids
wave_sequence = []     # ordered list of waves, each wave = set of FR ids

while unresolved FRs remain:
    # Step 1: Compute eligible set
    eligible = {fr | all(dep in resolved for dep in fr.depends_on)}
    eligible -= resolved

    # Step 2: Pack eligible FRs into this wave
    wave = {}
    for fr in eligible (stable order — sort by FR id):
        conflicts_with_wave = any(
            existing_fr conflicts_with fr   # via conflicts_with field OR
            OR overlapping touches_function entries
            for existing_fr in wave
        )
        if not conflicts_with_wave:
            wave.add(fr)

    # Step 3: FRs that were eligible but excluded due to conflicts
    # roll into the next iteration's eligible set automatically —
    # they are not resolved, so they re-qualify next wave.

    wave_sequence.append(wave)
    resolved.update(wave)
```

**Key properties:**
- A wave is never empty (progress guarantee: the packing step always admits at least one FR from the eligible set).
- Conflicts only delay, never deadlock — no circular soft-conflict cycles can form (they are undirected, not ordering edges).
- Hard edge cycles are a protocol violation; detect and abort at [F], not here.

---

## Worked Example

Four FRs in a phase:

```
FR-001  depends_on: []           conflicts_with: []         touches_function: [auth.py:validate_token]
FR-002  depends_on: []           conflicts_with: [FR-003]   touches_function: [auth.py:validate_token]
FR-003  depends_on: []           conflicts_with: [FR-002]   touches_function: [payments.py:charge]
FR-004  depends_on: [FR-001]     conflicts_with: []         touches_function: [reports.py:build_summary]
```

**Step 1 — Initial eligible set:** FR-001, FR-002, FR-003 (no unresolved depends_on). FR-004 is blocked by FR-001.

**Step 2 — Pack Wave 1:**
- Add FR-001. Wave = {FR-001}.
- Try FR-002. Conflicts with FR-001? No `conflicts_with` edge; `touches_function` overlap? Both touch `auth.py:validate_token` — conflict. Exclude FR-002.
- Try FR-003. Conflicts with FR-001? No. Add FR-003. Wave = {FR-001, FR-003}.
  - (FR-002 vs FR-003 is irrelevant — FR-002 already excluded this wave.)

**Wave 1: {FR-001, FR-003}** — dispatch in parallel.

**Step 3 — Resolve Wave 1.** resolved = {FR-001, FR-003}.

**Step 4 — Eligible for Wave 2:** FR-002 (no unresolved depends_on), FR-004 (FR-001 now resolved).

**Pack Wave 2:**
- Add FR-002. Wave = {FR-002}.
- Try FR-004. Conflicts with FR-002? No `conflicts_with` edge; no `touches_function` overlap. Add FR-004. Wave = {FR-002, FR-004}.

**Wave 2: {FR-002, FR-004}** — dispatch in parallel.

Result: 2 waves instead of 4 serial dispatches. FR-002's conflict with FR-003 forced them into separate waves; FR-001's `touches_function` overlap with FR-002 did the same for Wave 1.

---

## Per-Wave Dispatch

For each wave, dispatch all `docs-story-writer` instances in parallel:

**Each writer receives exactly:**
- Path to its own `.tmp/fr-context/FR-NNN.md`
- Path to `epic.md`
- Path to `vocab.md`

**Nothing else.** No sibling FR contexts, no dependency story bodies — frontmatter-only access to dependency stories is the story-writer's protocol responsibility.

**Collect from each writer:**
```
{
  fr_id:         "FR-NNN",
  status:        "success" | "failure",
  files_written: ["path/to/story.md", "path/to/design.md", ...],
  failures:      "error message"   # present on failure only
}
```

After a successful write, verify the writer deleted its own tmp file. A surviving tmp file for a "success" status is a protocol violation — treat it as a soft failure and surface it.

---

## Failure Handling

**Single writer failure:**
1. Retry once with identical inputs.
2. Second failure: add `fr_id` to the skip-and-report batch. Do NOT block other FRs in the same wave — failed writers are isolated.

**Dependency closure block:**
If a failed (skip-batch) FR appears in `depends_on` for any FR in a later wave, that successor wave is BLOCKED. Surface the blocked wave to the user:
```
BLOCKED: Wave N cannot start — FR-NNN failed and is a dependency for: FR-AAA, FR-BBB.
Options: (a) fix and resume from [S], (b) confirm skip and manually handle the successor FRs.
```
Do NOT auto-skip the dependency closure. The user decides.

**Retry-batch failures do not affect the current wave's other dispatches.** Parallelize normally; only block on the explicit dependency graph, not on peer failures.

---

## Idempotency on Resume

When resuming at [S] (via `[RESUME] → [S]`):

1. Read `meta.yaml` wave history — identify which waves and FRs are already marked shipped.
2. Scan `.tmp/fr-context/` for surviving files — these are FRs not yet dispatched (or whose writer failed without cleanup).
3. Cross-reference: FRs with no surviving tmp file and no shipped status are anomalous — surface them before proceeding.
4. Re-derive wave assignment from the current resolved set (same algorithm). Only dispatch FRs with surviving tmp files.

Shipped FRs are immutable. Do not re-dispatch a shipped FR even if its story.md looks stale — that is a separate concern for the reviewer or a manual fix.
