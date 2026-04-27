# Decision Memo — improve-skill
> Skill, change_request, `.brainstorms/2026-04-22-brainstorm-multi-artifact-output/design.md`, brainstorm-multi-artifact-output

## What I want

Teach improve-skill the flow-graph SKILL.md pattern so that when it reviews or repairs an existing SKILL.md it recognizes the structure, preserves it, and does not flatten it into prose or restructure it into a different format.

## Why this exists

The brainstorm-multi-artifact-output session established the flow-graph structure as the universal SKILL.md design principle. improve-skill works on existing skills — it must understand what a well-formed flow-graph SKILL.md looks like so it can evaluate conformance, make targeted changes inside the structure (add/remove/edit nodes, edges, Don'ts, Load declarations), and leave the graph topology intact.

Without this change, improve-skill could review a flow-graph SKILL.md and rewrite it into prose, strip node IDs, remove per-node Don'ts, or drop exit-condition edges — all of which silently degrade the skill.

## Injection shape

improve-skill receives a skill directory. It reads SKILL.md and companion files, evaluates against best practices, and produces improvements. This change extends the evaluation checklist to include flow-graph conformance checks and extends the production rules to require structure-preserving edits.

The synapse-brainstorm flow graph (verbatim below) is the **primary worked example** — improve-skill uses it as a reference for what a well-formed flow-graph SKILL.md looks like.

The abstract pattern definition lives in `skill-creator/references/skill-design-principles.md` (artifact 4 from the same brainstorm session). improve-skill should consume that reference for the canonical pattern.

## What it produces

Updated SKILL.md files that:
- Preserve flow-graph structure: MUST / MUST NOT / Entry / Flow sections intact
- Preserve node IDs (`### [A]`, `### [B]`, etc.) and edge declarations
- Preserve per-node Load / Do / Don't / Exit blocks
- Preserve self-loop edges and conditional routing
- Preserve the position-tracking convention (`Position: [node-id] — <context>`)
- Preserve [END] as a real node with explicit output, cleanup, and user-facing summary
- Preserve per-node companion loading declarations (not move them to a preamble)

When a SKILL.md is not yet flow-graph structured, improve-skill may propose migration — but must not silently convert a prose skill into a flow-graph without surfacing the structural change to the user.

## Architecture details

### Flow-graph SKILL.md structure (pattern definition)

Every SKILL.md should follow this structure:
1. **Purpose** (1 line) — what this skill does
2. **MUST** — global invariants, every turn
3. **MUST NOT** — global guardrails, every turn
4. **Entry** — [NEW] and [RESUME] entry points
5. **Flow** — nodes with Load / Do / Don't / Exit

**Node structure:** `### [ID] Name` → Load (companion files) → Do (sequential steps) → Don't (guardrails co-located with the action) → Exit (edges with conditions)

**Edge types:** self-loops explicit, conditions on every edge. Types: must (only option), should (conditional), can (optional).

**Position tracking:** agent records `Position: [node-id] — <context>` in notepad each turn.

**[END] node** — explicit terminal node that captures final output, cleanup, and user-facing summary. Not just a marker.

**Sub-nodes vs self-loops** — do not split Do steps into sub-nodes unless they span multiple turns with user interaction. Self-loops handle iteration. Position string carries granularity.

**Per-node companion loading** is about attention weight recency, not token saving. Content loaded at the moment it is needed gets higher attention priority than content loaded 30 turns ago.

**SKILL.md must stay lean (~80 lines)** because it is always-loaded — every line competes for attention every turn.

**Don'ts are co-located with the action** — high attention weight on guardrails right when they matter. Global guardrails go in MUST NOT (separate from per-node Don'ts).

### Conformance checks improve-skill must apply

When reviewing a SKILL.md, improve-skill checks:

1. **Top-level sections present:** Purpose, MUST, MUST NOT, Entry, Flow
2. **Node IDs explicit:** Every flow node has `### [ID] Name` heading
3. **Per-node Don'ts present:** Every node has a Don't block co-located with its Do block
4. **Exit conditions explicit:** Every node has an Exit block with labeled edges and conditions
5. **Self-loops declared:** Any iteration that stays on the same node has an explicit `→ [X] : <condition>` self-loop in the Exit block
6. **[END] is a real node:** Has Do steps (output, cleanup, summary), Don't guardrails, and an Exit declaration
7. **Position tracking in MUST:** MUST block includes "Record current position: `Position: [node-id] — <context>`"
8. **Per-node companion loading:** Load declarations appear inside each node, not only in a preamble
9. **Lean size:** SKILL.md is approximately 80 lines; bulk content is in on-demand companion files

### Structure-preserving edit rules

When improve-skill makes changes to a flow-graph SKILL.md:

- **Do not rename node IDs** without updating every edge that references them
- **Do not move Don'ts** out of their node into a global section (per-node placement is intentional)
- **Do not consolidate Load declarations** into a single preamble (recency is intentional)
- **Do not remove self-loop edges** — they make iteration explicit
- **Do not remove [END]** or reduce it to a comment — it is a real node
- **Do not add prose sections** that bypass the node/edge structure
- **Do not inflate SKILL.md** beyond ~80 lines — move new content to companion files and reference it via Load

### Worked example — synapse-brainstorm flow graph

This is a complete, well-formed flow-graph SKILL.md. improve-skill uses it as its primary reference.

<!-- VERBATIM -->
```markdown
Synapse-brainstorm discovers and pressure-tests artifacts (skills, tools, agents, protocols)
through structured coaching with lens evaluation, producing a design doc and per-artifact memos.

## MUST (every turn, before responding)
- Update notepad with current reasoning, thread states, and any new observations
- Update meta.yaml if artifact state changed (count, lens_complete, status)
- Record current position: `Position: [node-id] — <brief context>`
- Follow rules/coaching-policy.md (challenge, don't yes-man)
- If position is unclear, re-read this flow section before responding
- When writing structural content to notepad (directory trees, schemas, flow graphs, code blocks), prefix with `<!-- VERBATIM -->`

## MUST NOT (global)
- Never produce memos before Done Signal fires
- Never skip lenses during focus rotation
- Never add artifacts without user confirmation
- Never invent content not discussed in the brainstorm

## Entry

### [NEW] Fresh session
Load: templates/notepad.md, templates/meta.yaml
Do: create notepad + meta.yaml in `.brainstorms/<YYYY-MM-DD>-<slug>/`
Don't: skip wrong-tool check. Don't start Phase A without notepad initialized.
Exit:
  → [A] : artifacts initialized

### [RESUME] Paused session
Load: references/resume-protocol.md
Do: read meta.yaml for position + artifact states, read notepad for thread context
Don't: assume previous context — always re-read notepad and meta.yaml fresh.
Exit:
  → [A] : was in Phase A
  → [B] : was in Phase B (resume at last artifact in rotation)
  → [D] : was at Done Signal

## Flow

### [A] Phase A: classify + opening inventory
Load: references/artifact-criteria-{type}.md (per discovered type)
Do:
  1. Wrong-tool check — redirect if not artifact-worthy topic
  2. Classify brainstorm type + anticipated shape
  3. Opening inventory — exhaustive shallow list of all concerns (not a drip-feed)
  4. Identify initial artifacts — user confirms each ("should this be its own artifact?")
  5. Apply three-tier test to any companion candidates (tier 1/2/3?)
  6. Preview output shape: "This will produce ~N memos + 1 design doc"
Don't:
  - Drip-feed concerns across turns — all major concerns in opening inventory
  - Skip wrong-tool check even if topic seems obviously artifact-worthy
  - Auto-promote companions to artifacts without user confirmation
Exit:
  → [A] : more artifacts to identify or inventory to refine
  → [B] : user confirms inventory, Phase A gate passed

### [B] Phase B: focus rotation
Load: references/lens-*.md, references/focus-rotation.md
Do:
  1. Select next artifact from table (not yet lens-complete)
  2. Apply lenses in order: boundary → preciseness → robustness → maintenance → usability
  3. For tier 2+ companions: apply interface stability questions (boundary lens)
  4. Mark lens-complete in artifact table when all lenses pass
  5. If new artifact discovered mid-rotation: coaching pushback → user confirms → add to table
Don't:
  - Mark lens-complete without applying all 5 lenses
  - Agree without applying universal lenses (boundary + alternative) first — that's cheerleader drift
  - Skip interface stability questions for tier 2+ companions
  - Compress or summarize structural content (trees, schemas, flow graphs) in notepad — write verbatim
  - Write structural content to notepad without `<!-- VERBATIM -->` marker
Exit:
  → [B] : next lens on same artifact / next artifact in rotation
  → [H] : ~10 turns since last hygiene check
  → [D] : ALL artifacts marked lens-complete

### [H] Hygiene check
Load: references/hygiene-check.md
Do:
  1. Scan notepad for stale open points
  2. Check for forgotten artifacts or drifted threads
  3. Verify artifact table matches discussion state
  4. Quick 1-turn refresh — not a full lens rotation
Don't:
  - Turn hygiene into a full lens rotation — this is a quick glance, not a deep pass
  - Skip hygiene when it's due (~10 turns) — context window memory loss is real
Exit:
  → [B] : resume rotation where left off

### [D] Done Signal
Load: references/done-signal-checklist.md
Do:
  1. Verify all artifacts marked lens-complete in table
  2. Final hygiene check (mandatory)
  3. Cross-artifact boundary sweep:
     - Contract symmetry (every output has a consumer, every input has a producer)
     - Orphan detection (artifacts nothing depends on and that depend on nothing)
     - Circular dependency check
  4. Final circle-back — walk notepad thread-by-thread, confirm all terminal
Don't:
  - Fire Done Signal with any open threads remaining
  - Skip cross-artifact sweep — per-artifact lens-complete is necessary but not sufficient
  - Let user rush past unresolved gaps — push back with specific gaps named
Exit:
  → [O] : all preconditions met
  → [B] : gaps found — reopen specific artifacts

### [O] Output production
Load: agents/design-doc-producer.md, agents/memo-producer.md, templates/memo.md, templates/design-doc.md
Do:
  1. Dispatch design-doc-producer subagent (1 instance)
  2. Dispatch memo-producer subagents (N instances, one per artifact)
  3. All in parallel — design doc path is deterministic
  4. Aggregate results — verify all subagents reported via failure-reporting.md
  5. If any AGENT FAILURE: assess severity → retry or flag to user
Don't:
  - Dispatch without verifying all Done Signal preconditions passed
  - Silently swallow subagent failures — every failure must be surfaced
  - Compress or summarize notepad content passed to subagents — pass full notepad
Exit:
  → [END] : all subagents reported success
  → [D] : critical failure — reassess

### [END] Session complete
Do:
  1. Update meta.yaml: status → done
  2. Present summary to user:
     - Design doc path
     - List of memos produced (path + type: creation/change_request)
     - Any warnings from subagents
  3. Suggest next steps (prose, not deterministic routing)
Don't:
  - End without presenting the full output summary
  - Auto-route to next skill — suggest, don't deterministically dispatch
Exit:
  → (session ends)
```

### Registry detail sections

When improve-skill changes a skill's contracts (what it consumes or produces), it must update the corresponding `*_REGISTRY.md` detail section for that skill entry.

Registry format (Option C — hybrid summary + detail):

- **Summary table** at top: quick scan. Columns vary per registry type (Skills: Skill / Description / Domain / Status).
- **Detail sections** below: only for entries with contracts, `contains`, or non-trivial dependencies. Simple entries stay table-only.
- Detail section structure per entry:
  - **Consumes:** table of (Artifact, Contract, Required?)
  - **Produces:** table of (Artifact, Contract, Consumers)
  - **Contains:** table of (Type, Name, Purpose, Promotion) — for tier 2 companions

An entry gets a detail section if it has contracts (consumes/produces beyond trivial), contains tier 2 companions, or has non-obvious dependency relationships. Same format applies to SKILL_REGISTRY.md, AGENTS_REGISTRY.md, and PROTOCOL_REGISTRY.md.

## Dependencies (table)

| Artifact | Contract | Required? | Direction |
|----------|----------|-----------|-----------|
| `skill-creator/references/skill-design-principles.md` | Abstract flow-graph pattern definition | Yes | improve-skill consumes |
| `registry/SKILL_REGISTRY.md` | Skill entry + detail section (Consumes / Produces / Contains) | Yes | improve-skill updates on contract change |

## Edge cases considered

- **SKILL.md not yet flow-graph structured:** improve-skill should flag the deviation and propose migration, but must not silently restructure the file. Surface the structural change to the user before applying.
- **Node IDs renamed:** If improve-skill renames a node ID (e.g., `[A]` → `[PHASE_A]`), it must update every edge declaration that references the old ID in the same change.
- **Don'ts removed from a node:** Must not remove per-node Don'ts to "clean up" a verbose skill — co-location of guardrails with the action is intentional.
- **Load declarations consolidated:** Per-node Load declarations must not be merged into a global preamble — recency of loading at the relevant node is intentional (attention weight).
- **[END] reduced to a marker:** [END] is a real node; if improve-skill finds an [END] with no Do / Don't / Exit blocks, it should flag and propose completing it, not remove it.
- **SKILL.md inflated beyond ~80 lines:** If a change would push SKILL.md past ~80 lines, improve-skill should move new content to a companion file and add a Load reference at the appropriate node, rather than growing the SKILL.md inline.

## Companion files anticipated

- `skill-creator/references/skill-design-principles.md` — abstract flow-graph pattern; improve-skill reads this as the canonical reference (produced by the same brainstorm session as a separate change request to skill-design-principles)

## Open questions

None. All threads resolved in the brainstorm session.
