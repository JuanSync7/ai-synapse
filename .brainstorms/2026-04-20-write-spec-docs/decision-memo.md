# Decision Memo — write-spec-docs (rewrite)

## What I want

Rewrite the orchestration architecture of write-spec-docs. Replace the wave-parallel dispatch system with a sequential subagent queue, add a planning notepad for the main agent to reason and iterate before dispatching, add per-section and doc-level review agents, and add an update mode so patch-docs can call it for structural changes without a full rewrite.

## Why Claude needs it

Single-agent spec writing degrades toward the end of long documents. By section 6+, the agent is simultaneously deciding *what to say* and *how to say it* across accumulated context, leading to weaker rationale, vaguer acceptance criteria, and sloppy cross-references in late sections. The existing wave-parallel system was designed to fix this but references `parallel-agents-dispatch` which doesn't exist as a tool — so in practice, the agent falls back to single-pass writing. There is also no review loop (just a manual compliance note), no update mode (the Wrong-Tool Detection punts with "read the existing spec first and revise"), and the planning stage is data shuffling rather than reasoning.

## Injection shape

**Workflow + judgment.** The skill teaches the planner how to decompose a spec into sections, what context each subagent needs (reference vs. inline), when to use which model, and how to propagate discoveries forward through the sequential chain. The judgment layer is in brief construction and cross-ref planning; the workflow layer is the dispatch/review/update loop.

## What it produces

Two persistent artifacts per spec:
- `*_SPEC.md` — the specification document (with `<!-- sec:id -->` anchors for navigation)
- `*_SPEC_MAP.md` — companion knowledge graph index (skeleton + sections table + entity index + REQ index)

One ephemeral artifact per run:
- Planning notepad — section briefs, signals log, decisions, rejected briefs (not persisted after run)

## Architecture

### Agents (3 definitions, scoped to this skill)

| Agent | Domain/Role | Model | Primary output | Structured output |
|-------|-------------|-------|---------------|-------------------|
| `docs-spec-section-writer` | docs/writer | Per brief (Opus or Sonnet) | Section written to spec file | Sidecar: signals + thought summary |
| `docs-spec-section-reviewer` | docs/reviewer | Sonnet | None | Verdict + thought summary + reject reasoning + notes |
| `docs-spec-coherence-reviewer` | docs/reviewer | Sonnet | None | PASS or per-section rejection list + thought summary |

**Writer** has two prompt modes (create/update), writes directly to the spec file via Edit, navigates via doc map + section anchors (never full-file reads), validates its own input (rejects incomplete briefs back to planner). Tools: Edit, Read, Grep, Glob, Agent (Explore), WebSearch/WebFetch.

**Per-section reviewer** evaluates three-way: brief alignment + section quality + deviation justification. Deviation-with-reasoning is NOT automatic rejection — writer may have improved on the brief.

**Coherence reviewer** evaluates doc-level: alignment, coherency, flow, narrative arc, cross-ref consistency, verification checklist (traceability completeness, REQ coverage). Does not review per-requirement technical quality.

### Flow

```
CREATE MODE:
  1. Planner reads inputs + template.md
  2. Creates: notepad (ephemeral), spec skeleton (anchors), doc map (empty)
  3. Produces section briefs in notepad (can iterate freely)
  4. Per-section loop (sequential):
     a. Finalize brief (references for existing content, inline for new)
     b. Dispatch writer → writes to file + returns sidecar
     c. Dispatch per-section reviewer → verdict
     d. PASS: planner updates doc map + scans all remaining briefs
        REJECT: planner revises brief, retry once, then NEEDS_MANUAL
  5. Coherence review → PASS or per-section rejections
  6. If rejections: update mode for those sections → second coherence pass
     Still failing → fail loudly with precise summary table
  7. Finalization: surface NEEDS_MANUAL items, update README dashboard

UPDATE MODE:
  1. Reads existing spec + existing doc map as base
  2. Identifies affected sections from change context
  3. Same per-section loop (writer in update prompt mode)
  4. Coherence review on full doc
  5. Finalization
```

### Key Design Decisions

- **Section anchors** (`<!-- sec:id -->`) instead of line numbers — immune to content growth shifting line ranges
- **Document map as knowledge graph** — agents navigate by entity/section relationships, not file scanning
- **Briefs use references for existing content, inline for new** — keeps briefs compact, cross-refs resolve at execution time from actual written content
- **Planner active throughout** — updates doc map, revises upcoming briefs, propagates signals between sections (not plan-once-execute-many)
- **All agents follow failure-reporting protocol** — `AGENT FAILURE: [name] <context> [reason]`, continue through all issues, return complete summary
- **Max 1 retry everywhere** — per-section and coherence. Prevents infinite loops. Unresolvable items surface to user with specific, answerable questions.

## Edge cases considered

| Edge case | Resolution |
|-----------|------------|
| Quality degradation in late sections | Core problem — solved by sequential subagent queue with isolated context per section |
| Cross-ref staleness between sections | Briefs reference doc map entities; writer resolves at execution time from actual content |
| Line numbers shift after each write | Section anchors (`<!-- sec:id -->`) eliminate this class of bugs |
| Writer deviates from brief with good reason | Reviewer evaluates three-way (brief + section + sidecar); justified deviation = PASS-with-note |
| Writer receives incomplete brief | Writer validates input, returns "need from planner: [X]" — counts toward retry limit |
| Infinite rejection loop | Max 1 retry per section, max 1 coherence re-pass. NEEDS_MANUAL after that. |
| Malformed existing spec in update mode | Best-effort update, explicitly state what was broken/skipped |
| Large update affecting most sections | Same pipeline — no threshold needed, sequential queue handles any count |
| Context window growth during orchestration | Compact-safe by design — notepad + doc map + spec file externalize all state |
| Coherence issues after all sections pass individually | Coherence reviewer catches doc-level problems that per-section review can't see |

## Companion files anticipated

### agents/
- `docs-spec-section-writer.md` — writes sections, two prompt modes (create/update), sidecar output, doc map navigation, input validation
- `docs-spec-section-reviewer.md` — three-way evaluation (brief + section + sidecar), deviation-with-reasoning policy
- `docs-spec-coherence-reviewer.md` — doc-level coherency, verification checklist, per-section rejection format

### templates/
- `template.md` — (existing, preserved) spec document structure
- `notepad.md` — planning notepad template (section briefs, signals log, decisions, rejected briefs)
- `spec-map.md` — doc map + skeleton template (sections table, entity index, REQ index)

### references/
- `phased-delivery.md` — (existing, preserved)
- `readme-update-contract.md` — (existing, preserved)

### Protocol dependencies
- `src/protocols/external-memory/` — shared pattern for file-based working memory (to be created)
- `src/protocols/failure-reporting/` — standardized failure tags (created during this brainstorm)

## What's preserved from current skill

template.md, requirement format (REQ-xxx blockquotes, anti-patterns, examples), quality standards, input gathering, layer context, wrong-tool detection (add update mode), verification checklist (moved to coherence reviewer), phased delivery, document chain + integration.

## What's removed

`section_context_map` schema, wave dependency graph, `parallel-agents-dispatch` references, progress tracking TaskCreate boilerplate.

## External impacts (already actioned)

| Target | Action | Status |
|--------|--------|--------|
| patch-docs | Change request: escalation model Sonnet→Opus, _SPEC_MAP.md awareness | Created |
| write-spec-summary | Change request: consider reading _SPEC_MAP.md | Created |
| autonomous-orchestrator | Change request: _SPEC_MAP.md as output artifact | Created |
| skill-brainstorm | Check change_requests/ folder on entry | Done |
| failure-reporting protocol | Created during brainstorm | Done |
| GOVERNANCE.md | change_requests/ convention documented | Done |
| AGENT_TAXONOMY.md | Added `docs` domain, `writer` and `reviewer` roles | Done |

## Open questions

None — all threads resolved during Phase B.
