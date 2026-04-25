# Decision Memo — synapse-brainstorm (née skill-brainstorm)

> Artifact type: skill | Memo type: change_request | Design doc: `.brainstorms/2026-04-22-brainstorm-multi-artifact-output/design.md`

---

## What I want

Full rework of skill-brainstorm, renamed to synapse-brainstorm:

1. Generalize from "brainstorm one skill" to "brainstorm any collection of artifacts from any entry point" (skill, tool, agent, protocol).
2. Replace single-memo output with three output types: notepad, design doc, N memos.
3. Introduce structured focus rotation (Phase B) with five lenses per artifact, loaded per-lens (not bulk).
4. Replace the current flat SKILL.md with a flow-graph SKILL.md (~80 lines).
5. Add [N] artifact focus node — dedicated per-artifact exploration separate from session-level thinking.
6. Add two-system notepad: session-level (free-form) + per-artifact sections (structured: Resolved / Resolved not fleshed / Open / Memo-ready).
7. Add meta.yaml artifact tracking for resume support.
8. Dispatch two subagent types at Done Signal (design-doc-producer, memo-producer) in parallel.
9. Unified memo placement: all memos go to `artifact_dir/change_requests/`.
10. Add hygiene checks (~every 10 turns) to combat context window memory loss.
11. Add unified naming convention with taxonomy validation at artifact discovery.

---

## Why Claude needs it

The test coverage engine brainstorm produced content for 6 skills, 11 tools, and project-level strategy, but the memo template only supported one memo per session. Three root causes:

1. The memo template had no section for architectural details and no filtering rule distinguishing decisions from process.
2. "One brainstorm → one memo" breaks when a session discovers multiple artifacts, each needing its own scoped handoff.
3. skill-brainstorm scope was limited to skills, forcing workarounds when other artifact types were discovered.

Without the redesign, multi-artifact brainstorms lose structural details (directory trees, schemas, flow graphs) to prose compression, and non-skill artifacts have no brainstorm pathway.

---

## Injection shape

**Workflow** — the skill orchestrates a multi-phase brainstorm with structured output production. The injection is primarily:
- **Workflow:** Phase A (session-level discovery) → [N] (per-artifact focus) → Phase B (lens rotation) → Done Signal → subagent dispatch
- **Policy:** Coaching behavior (pushback, challenge, aggressive distillation into per-artifact sections)
- **Domain knowledge:** Artifact-type criteria, lens definitions, naming conventions loaded on-demand

---

## What it produces

Three output types per session:

| Output | Count | Mutable? | Purpose |
|---|---|---|---|
| Notepad | 1 | Yes (every turn) | Process memory — complete evolution record (how, why, what) |
| Design doc | 1 | No (frozen) | Design intent — "why was it designed this way" |
| Memo / Change request | N (one per artifact) | No (handoff) | Per-artifact spec for `*-creator` skills |

**Memo placement:** All memos go to `artifact_dir/change_requests/` regardless of new vs existing. No routing logic. Directory created if needed.

**Design doc path:** `.brainstorms/<YYYY-MM-DD>-<slug>/design.md`

---

## Flow graph

<!-- VERBATIM -->
```
Entry:
  [NEW]  → [A]           Fresh session — create notepad + meta.yaml
  [RESUME] → [A|B|D]     Paused session — read meta.yaml for position

Flow:
  [A] Session-level ──→ [N] Artifact focus ──→ [A]  (discovery loop)
       │                      │
       │                      └──→ [B]  (inventory complete)
       │
       └──→ [B]  (inventory complete, no new artifacts)

  [B] Lens rotation ──→ [B]  (next lens / next artifact)
       │                 │
       │                 ├──→ [N]  (new artifact discovered mid-rotation)
       │                 └──→ [H]  (~10 turns since last hygiene)
       │
       └──→ [D]  (all artifacts lens-complete)

  [H] Hygiene ──→ [B]  (resume rotation)

  [D] Done Signal ──→ [O]  (all preconditions met)
       │
       └──→ [B]  (gaps found — reopen)

  [O] Output ──→ [END]  (all subagents reported)
       │
       └──→ [D]  (critical failure)

  [END] Session complete
```

### Node specifications

**[NEW]** — Load: templates/notepad.md, templates/meta.yaml. Create brainstorm directory + notepad + meta.yaml. Wrong-tool check. Exit → [A].

**[RESUME]** — Load: references/resume-protocol.md. Read meta.yaml + notepad. Exit → [A|B|D] based on saved position.

**[A] Session-level** — Load: references/artifact-criteria-{type}.md per discovered type. Wrong-tool check, classify brainstorm type, opening inventory (exhaustive, not drip-feed), manage cross-cutting/process/open sections. Don't discuss artifact-level details. Exit → [N] when artifact discovered, → [B] when inventory complete + user confirms + no unassigned open points.

**[N] Artifact focus** — Load: references/naming-conventions.md. Confirm artifact type, suggest name from taxonomy pattern, validate against taxonomy, discuss + flesh out artifact, create per-artifact section (Resolved / Resolved not fleshed / Open / Memo-ready), distill session-level points that belong here. Don't proceed without user-confirmed name. Exit → [A] (more to discover), → [B] (inventory complete), → [N] (self-loop, still fleshing out).

**[B] Lens rotation** — Load: references/lens-{current}.md (per-lens, always re-load), references/focus-rotation.md. Apply lens order: boundary → preciseness → robustness → maintenance → usability. Mark lens-complete per artifact. Don't bulk-load lenses. Exit → [B] (self-loop), → [N] (new artifact mid-rotation), → [H] (~10 turns), → [D] (all lens-complete).

**[H] Hygiene** — Load: references/hygiene-check.md. Quick 1-turn scan for stale points, forgotten artifacts, drifted threads. Not a full rotation. Exit → [B].

**[D] Done Signal** — Load: references/done-signal-checklist.md, references/cross-artifact-sweep.md. Verify all lens-complete, final hygiene, cross-artifact sweep (contract symmetry, orphan detection, circular deps), verify all per-artifact Open empty, verify session-level open resolved. Exit → [O] (all clear), → [B] (gaps found).

**[O] Output** — Load: agents/design-doc-producer.md, agents/memo-producer.md, templates/. Dispatch design-doc-producer (1) + memo-producer (N) in parallel. Full notepad passed to each. Verify via failure-reporting.md. Exit → [END], → [D] (critical failure).

**[END]** — Update meta.yaml status → done. Present summary (design doc path, memo list, warnings). Suggest next steps.

### Entry gates

| Transition | Gate |
|---|---|
| [A] → [B] | Artifact inventory confirmed by user. No unassigned session-level Open points. |
| [B] → [D] | All artifacts marked lens-complete. |
| [D] → [O] | All per-artifact Open empty. Cross-artifact sweep passed. Session-level resolved. |

---

## Notepad architecture

### Two-system model

**Zone 1 — Session-level (top, free-form):**
- Status (phase, type, count)
- Artifacts Discovered (index table linking to per-artifact sections)
- Cross-cutting (shared decisions spanning 2+ artifacts)
- Process (lens progress, coaching reasoning, discarded alternatives — the "why" record, does NOT transfer to memos)
- Open/orphaned (must be empty before Done Signal)

**Zone 2 — Per-artifact sections (below, structured):**

Each artifact section:

<!-- VERBATIM -->
```
## Artifact: {name}
Type: {type} | Name: {validated-name} | Convention: {pattern} ✓

### Resolved
- fully fleshed decisions

### Resolved (not fleshed)
- decision made, creator thinks deeper (brevity IS the signal)

### Open
- ⚠ blocks Done Signal

### Memo-ready
<!-- VERBATIM -->
structural blocks copied verbatim to memo
```

### Evolution principle

Main agent distills aggressively into per-artifact sections. Anything with a home in an artifact goes there. Cross-cutting stays cross-cutting only when it genuinely spans 2+ artifacts. Items move between session-level and per-artifact during turns. The notepad captures complete evolution: how, why, what was done, what's finalized.

Session-level process section is the brainstorm's "thinking" — lens observations, coaching pushback reasoning, discarded alternatives. This does NOT transfer to memos but stays as the "why did we decide X" record.

---

## Naming conventions

### Unified pattern

All artifact types: `{domain}-{subdomain?}-{purpose?}-{terminal}` where terminal is type-specific:

| Artifact | Terminal | Source |
|---|---|---|
| Agent | role (judge, writer, reviewer, auditor, prompter) | AGENT_TAXONOMY.md |
| Protocol | type (trace, schema, contract) | PROTOCOL_TAXONOMY.md |
| Tool | action (scorer, generator, validator, parser, transformer, reporter) | TOOL_TAXONOMY.md |
| Skill | intent (write, review, improve, etc.) | SKILL_TAXONOMY.md |

Subdomain and purpose are optional. Taxonomy files validate domain + terminal segments.

### Examples

| Name | Segments |
|---|---|
| `skill-eval-judge` | domain-subdomain-role (3) |
| `docs-spec-section-writer` | domain-subdomain-purpose-role (4) |
| `observability-execution-trace` | domain-purpose-type (3) |
| `testing-criticality-scorer` | domain-purpose-action (3) |

`references/naming-conventions.md` (tier 2, shared with skill-creator) carries full patterns + good/bad examples + taxonomy lookup rules.

---

## Three-tier companion model

| Tier | Location | Discovery | Registry? |
|---|---|---|---|
| 1 — specific | skill-dir/ | `Load:` in SKILL.md | No |
| 2 — generic, one consumer | skill-dir/ (structurally same as tier 1) | `Load:` in SKILL.md | No |
| 3 — promoted, multiple consumers | `src/agents/<domain>/` etc. | Registry | Yes |

- Tier 1 and 2 are structurally identical. Naming alignment is the only upfront enforcement.
- Promotion = extract and replace, never duplicate. One copy at any point.
- Detection: `scripts/audit-artifacts.sh` flags duplicates + should-be-symlinks. `fix` subcommand auto-converts.
- `contains` registry field is NOT needed — dropped from original design.

---

## Edge cases considered

| Edge case | Handling |
|---|---|
| Artifact discovered mid-lens-rotation | [B] routes to [N], user confirms, per-artifact section created, return to [B] |
| Cross-artifact sweep fails at Done Signal | [D] reopens specific artifacts via → [B] |
| Critical subagent failure at output | [O] routes → [D] for reassessment |
| Resume after compaction | meta.yaml (machine state) + notepad (thread context), both re-read fresh |
| Topic not artifact-worthy | [A] wrong-tool check redirects before discovery |
| Companion auto-promoted without user consent | [N] Don't blocks — user confirmation required |
| High artifact count (17+) | Accepted tension — per-artifact sections manage complexity |
| Session-level point belongs to artifact | Main agent distills into per-artifact section |
| Lens already in context from prior artifact | Always re-load — attention weight recency |
| Duplicate companion across skills | audit-artifacts.sh signals → promotion candidate |
| Copy exists alongside promoted version | audit-artifacts.sh fix → auto-symlink |

---

## Companion files anticipated

### Always-loaded (3)
- `rules/brainstorm-constraints.md` — hard rules (never skip lenses, never produce memo before Done Signal)
- `rules/coaching-policy.md` — coaching behavior (pushback, challenge, aggressive distillation)

### Templates (5)
- `templates/notepad.md` — two-system notepad template with per-artifact section structure
- `templates/meta.yaml` — artifact tracking template
- `templates/memo.md` — memo output template
- `templates/design-doc.md` — design doc output template
- `templates/change-request.md` — change request format

### Artifact criteria (4)
- `references/artifact-criteria-{skill,tool,agent,protocol}.md` — loaded at [A] per discovered type

### Lens definitions (5 + 1)
- `references/lens-{boundary,preciseness,robustness,maintenance,usability}.md` — loaded per-lens at [B]
- `references/cross-artifact-sweep.md` — loaded at [D], separate from lens-boundary

### Process references (5)
- `references/naming-conventions.md` — loaded at [N], tier 2 shared with skill-creator
- `references/hygiene-check.md` — loaded at [H]
- `references/focus-rotation.md` — loaded at [B]
- `references/done-signal-checklist.md` — loaded at [D]
- `references/resume-protocol.md` — loaded at [RESUME]

### Subagent prompts (2)
- `agents/design-doc-producer.md` — loaded at [O]
- `agents/memo-producer.md` — loaded at [O]

**Total: ~25 files (22 on-demand, 3 always-loaded). Deferred: 4 artifact-type-specific lens files.**

---

## Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `registry/*_REGISTRY.md` | Consumes | Read at [O] for creation vs change_request detection |
| `failure-reporting.md` | Consumes | Subagent failure protocol |
| `*-creator` skills | Produces for | Memos in `artifact_dir/change_requests/` |
| `taxonomy/*.md` | Consumes | Naming validation at [N] |
| `scripts/audit-artifacts.sh` | Consumes (optional) | Promotion signals during boundary lens |

---

## Open questions

None. All threads resolved. See design doc § "What Changed From the Original Change Request" for the 12 post-memo resolutions and § "Accepted Tensions" for deferred items.
