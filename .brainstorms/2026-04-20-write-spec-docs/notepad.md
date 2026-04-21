# Brainstorm Notes — write-spec-docs

## Status
Phase: B (final review)
Outcome: skill (rewrite of existing skill's orchestration architecture)

## Core Problem
Quality degrades toward the end of long spec docs due to context exhaustion. Single-agent spec writing forces simultaneous "what to say" + "how to say it" across all sections in one pass.

## Architecture Decisions

### Execution Model
- Sequential subagent queue (not waves/parallel). Sequential gives better cross-ref control.
- Wave/parallel approach (existing SKILL.md) is discarded — adds orchestration complexity without quality benefit, and `parallel-agents-dispatch` doesn't exist as a tool.
- Token cost accepted: better quality is worth more tokens.

### Planning Phase (Opus, main agent)
- Planner reads all inputs + template.md, produces a planning notepad (ephemeral, per-run).
- Creates spec file (skeleton with H2 headings + `<!-- sec:id -->` anchors) and doc map file (persistent, alongside spec).
- Produces section briefs in notepad. Can freely revise before and between section dispatches.
- Model assignment per section is decided during planning and recorded in the brief (not dynamically chosen).
- Key instruction: "All planning state lives in the notepad file. Do not rely on in-context memory for cross-section decisions."

### Briefs
- Briefs use **references** (pointers to doc map entities/anchors) for content that already exists. Only **inline** actual info when the referenced content doesn't exist yet (e.g., first section).
- One brief per section. After section is written, that brief is frozen (historical record).
- Planner updates upcoming briefs between section dispatches based on signals and doc map changes.

### Section Anchors (not line numbers)
- Planner writes `<!-- sec:id -->` / `<!-- /sec:id -->` anchor pairs into skeleton.
- All agents locate sections by grepping for anchors. Line numbers are never used for navigation.

### Document Map (Knowledge Graph Index) — Persistent File
- Lives alongside the spec doc as `_SPEC_MAP.md`. Persists across runs.
- Contains: skeleton (headings + anchors) + sections table (ID, status, heading) + entity index (entity → defined in → referenced by) + REQ index (range → section → count).
- Planner owns writes. Updated after each section write.
- Agents read the doc map to navigate without full-file reads. Agents NEVER write to the doc map.
- Coherence reviewer uses entity index for structural integrity checks ("entity X referenced but never defined").

### Notepad (Ephemeral, Per-Run)
- Planning workspace only — does not persist across runs.
- Contains: spec file path, doc map file path, section briefs, signals log, decisions, rejected briefs.
- Compact-safe by design: notepad + doc map + spec file externalize all state. Architecture survives auto-compaction naturally.
- No explicit /compact needed — realistic planner context stays at 35-50k.

### External Memory Protocol
- External memory is a PROTOCOL (`src/protocols/external-memory.md`), not a skill.
- Protocol defines: file-based, compaction-safe, skill-owned (subagents don't write), read-before-reason/write-after-turn discipline.
- Protocol is thin (~30-40 lines). Notepad templates stay in each skill's `templates/` directory.
- Signals sidecar is protocol-level (optional clause): "subagents MAY return signals; planner reads and decides whether to update notepad."

## Agent Definitions

### spec-section-writer.md
- Writes individual sections directly to the spec file (no returning text to planner for assembly).
- **Two prompt modes:** create ("section is empty, here's the brief") vs. update ("section exists, here's what needs to change and why"). Different prompts, same output structure.
- **Tools:** Edit, Read, Grep, Glob, Agent (Explore subagent for codebase exploration), WebSearch/WebFetch (verify claims).
- **Navigates via doc map:** reads doc map file → finds section anchor → greps anchor in spec → reads targeted range. Never reads full spec file.
- **Validates its own input:** if brief is incomplete/contradictory, returns early with "need from planner: [specific items]" rather than guessing.
- **Output:** writes section to file (primary) + returns sidecar as final Agent response text (signals: new entities, cross-ref discoveries, assumptions; thought summary: deviations from brief explained, structural choices made).
- **Failure pattern:** continues working through all issues encountered, accumulates them, then returns a complete failure summary table. Does not bail on first problem.

### spec-section-reviewer.md (Sonnet)
- Validates individual sections after writing.
- **Receives THREE inputs:** (1) the dispatched brief, (2) the written section, (3) the FULL writer sidecar (signals + thought summary).
- **Evaluates three-way:** brief alignment + section quality + deviation justification.
- **Deviation-with-reasoning is NOT automatic rejection.** Writer may have discovered information that improves on the brief. Reject ONLY when: quality defects exist, writer deviated without explanation, or writer's reasoning is flawed.
- **Output:** structured response with: verdict (PASS / PASS-with-note / REJECT) + thought summary (reasoning behind verdict) + reject reasoning (actionable, specific — what's wrong and what planner should fix; only on REJECT) + notes (doc map updates, upstream impact, brief-drift acknowledgment; on PASS/PASS-with-note).
- **Failure pattern:** accumulates all issues across the section, returns complete list. Does not stop at first defect.

### spec-coherence-reviewer.md (Sonnet)
- Reviews full assembled doc after all sections are written.
- **Receives:** full spec doc + doc map file.
- **Focuses on:** alignment, coherency, flow, narrative arc, cross-ref consistency, verification checklist (traceability completeness, REQ coverage). Does NOT review technical/requirement quality per-section (that's spec-section-reviewer's job).
- **Output:** PASS or per-section rejection reasoning (which sections have issues, what specifically is wrong with the doc-level coherency).
- Rejection goes to planner → planner enters update mode for those sections → same write/review loop.
- **Failure pattern:** accumulates all coherency issues across entire doc, returns complete summary. Does not stop at first issue found.

## Per-Section Loop

```
For each section:
  1. Planner finalizes brief (references for existing, inline for new)
  2. Dispatch spec-section-writer (model as specified in brief)
     → Writes to file + returns sidecar
     OR → Rejects brief with "need from planner: [X]" (counts toward retry limit)
  3. Dispatch spec-section-reviewer (Sonnet)
     → Receives: brief + section + full sidecar
     → Returns: verdict + thought summary + reject reasoning + notes
  4. PASS/PASS-with-note:
     → Planner updates doc map (section status, entity index, REQ index)
     → Planner scans ALL remaining briefs for affected cross-refs, updates as needed
     → Next section
  5. REJECT (or writer brief-rejection):
     → Planner revises brief using rejection/need signal
     → Retry once (back to step 2)
     → Second rejection → NEEDS_MANUAL, continue with remaining sections
```

## Coherence Review

```
After all sections complete:
  1. Dispatch spec-coherence-reviewer (Sonnet)
     → Reads full doc + doc map
     → Returns: PASS or per-section rejection list
  2. If rejections:
     → Planner enters update mode for rejected sections
     → Same per-section loop (update prompt mode), max 1 retry per section
  3. Second coherence pass:
     → Dispatch spec-coherence-reviewer again
     → If still has issues → fail loudly with precise summary table to user
  4. If PASS → finalization
```

## Retry / Failure Pattern (Universal)

- **All agents:** continue working through all issues, accumulate, return complete failure summary. Never bail on first problem.
- **Per-section:** max 1 retry (whether writer rejects brief or reviewer rejects section). Second failure → NEEDS_MANUAL.
- **Coherence:** max 1 retry (rewrite rejected sections, re-run coherence). Second failure → fail loudly to user.
- **NEEDS_MANUAL surfacing:** planner synthesizes all rejection signals into specific, answerable questions — "what is the auth token lifecycle? I found conflicting signals in [source A] vs [source B]." Not vague "need more info." This logic lives in SKILL.md (planner behavior).

## Update Mode

- **Trigger:** receives existing spec file + existing doc map + change context (from patch-docs escalation or user request).
- **Detection:** presence of existing spec file = update mode.
- **Planner:** reads existing doc map as base → identifies affected sections from change context → produces update briefs for those sections only. May add new anchors/sections to skeleton if change requires new H2s.
- **Execution:** same per-section loop with writer in update prompt mode → same coherence review on full doc.
- **Doc map:** incrementally updated, not rebuilt from scratch.

## Boundary

- **Upstream:** orchestrator/user provides input. write-spec-docs never brainstorms requirements.
- **Downstream:** produces finished spec + doc map, never implements.
- **patch-docs:** surgical patch vs. structural escalation to write-spec-docs. patch-docs should dispatch write-spec-docs at Opus (not Sonnet) since it's an orchestrator.
- **Always a leaf node** — produces doc, hands back to caller.
- **write-spec-docs owns section structure** — it's the expert. Orchestrator delegates content/material.

## What's Preserved from Current Skill

- template.md (document structure)
- Requirement format (REQ-xxx blockquotes, acceptance criteria, anti-patterns)
- Quality standards (active voice, concrete values, testable language)
- Input gathering (priority-tiered questions, "infer before asking")
- Layer context + wrong-tool detection (add update mode redirect)
- Verification checklist (now owned by coherence reviewer)
- Phased delivery references
- Document chain + integration

## What's Replaced

- Planning stage (section_context_map → notepad-based planning with iteration)
- Execution stage (wave-parallel dispatch → sequential subagent queue)
- Added: per-section review gate, coherence review, update mode
- Added: doc map as persistent knowledge graph index
- Added: section anchors (not line numbers)
- Removed: section_context_map schema, wave dependency graph, parallel-agents-dispatch references, progress tracking TaskCreate boilerplate

## SKILL.md vs Agent Definition Split

- **SKILL.md** = planner instructions: phases, notepad contract, update mode detection, model policy, brief production, between-section checklist, NEEDS_MANUAL surfacing, doc map ownership.
- **agents/spec-section-writer.md** = executor instructions: brief→draft+sidecar, requirement format rules, analyze→scope→group→write→number→trace steps, doc map navigation, input validation, two prompt modes.
- **agents/spec-section-reviewer.md** = evaluator instructions: three-way evaluation logic, deviation-with-reasoning policy, structured output format.
- **agents/spec-coherence-reviewer.md** = doc-level evaluator: alignment/coherency/flow focus, verification checklist, per-section rejection format.
- SKILL.md must NOT repeat agent execution rules. SKILL.md must produce briefs that exactly match what spec-section-writer.md expects.

## Companion Files

### agents/
- `spec-section-writer.md`
- `spec-section-reviewer.md`
- `spec-coherence-reviewer.md`

### templates/
- `template.md` — (existing) spec document structure
- `notepad.md` — planning notepad template (ephemeral, per-run)
- `spec-map.md` — doc map + skeleton template (persistent, alongside spec)

### references/
- `phased-delivery.md` — (existing)
- `readme-update-contract.md` — (existing)

### Protocol dependency
- `src/protocols/external-memory.md` — shared pattern for file-based working memory (to be created)
- Failure reporting protocol (`src/protocols/failure-reporting.md`) — two levels:
  - `AGENT FAILURE: [agent-name] <free-form context> [reason]` — agent couldn't complete its task
  - `PROTOCOL FAILURE: [protocol-name] <free-form context> [reason]` — protocol contract was violated
  - Name and reason are MUST. Free-form middle is optional context (section-id, what was attempted, etc.)
  - No SKILL FAILURE — skills are instructions, not executors. Skill-level failures are reported as AGENT FAILURE with skill context.

### Change requests to produce
- `src/skills/docs/patch-docs/change_requests/` — update escalation model tier (Sonnet → Opus), add _SPEC_MAP.md awareness
- `src/skills/docs/write-spec-summary/change_requests/` — consider reading _SPEC_MAP.md instead of full spec
- `src/protocols/external-memory/` — to be created (new protocol)

### Governance
- Change request mechanism documented in GOVERNANCE.md — folder-based (`change_requests/`), one file per request, deleted after implementation

### patch-docs fix
- `src/skills/docs/patch-docs/references/escalation-policy.md` — update model tier for write-spec-docs dispatch from Sonnet to Opus
