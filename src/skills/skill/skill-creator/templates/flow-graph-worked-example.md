# Flow-Graph Worked Example — synapse-brainstorm

Frozen snapshot of a real flow-graph SKILL.md. Shows the pattern applied to a multi-phase coaching skill with subagent dispatch. Use as a concrete reference, not as a golden truth of the latest version.

---

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
