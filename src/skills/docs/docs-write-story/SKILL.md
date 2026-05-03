---
name: docs-write-story
description: "Use when an engineering brainstorm is ready to become a buildable spec, when asked to materialize a brainstorm memo into ticket-shape FR directories, or when asked to write engineering specs as story / design / impl / test slices."
domain: docs.spec
intent: write
tags: [ticket-shape, vertical-slice, engineering-docs, fr-decomposition]
user-invocable: true
argument-hint: "<brainstorm-memo-path> [--initiative <name>] [--epic <name>]"
---

Materializes a brainstorm memo into ticket-shape engineering docs: epic.md / vocab.md updates, parallel per-FR vertical slices (story+design+impl+test), and a regenerated engineering guide. Replaces the legacy 4-stage horizontal pipeline (write-spec-docs → write-design-docs → write-implementation-docs → write-test-docs) for engineering systems — vertical slices preserve atomic per-FR context that horizontal sweeps lose.

> **Execution scope:** Ignore `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, and `test-inputs/` during execution — these are used only by improvement and migration workflows.

> **Always load** `synapse/protocols/docs/docs-engineering-ticket-shape/docs-engineering-ticket-shape.md` — every node writes or validates artifacts that must conform to it.

## MUST (every turn)
- Update `meta.yaml` with current position, FR roster state, and tmp-file inventory before responding
- Set `model:` explicitly on every subagent dispatch
- Record position: `Position: [node-id] — <context>`
- Verify `version:` in every artifact written matches the protocol version
- When writing structural content (FR rosters, frontmatter blocks, directory trees) into `.tmp/fr-context/` files, prefix with `<!-- VERBATIM -->`

## MUST NOT (global)
- Never delegate orchestration (FR fan-out, wave dispatch) to a subagent — orchestration is the skill's territory
- Never let a story-writer read the body of a dependency story.md — frontmatter only
- Never produce epic-level design.md / impl.md / test.md — model cross-cutting work as foundational stories (FR-000-style)
- Never hand a story-writer more than its own tmp context file — atomic FR context is load-bearing
- Never proceed past the FR-roster gate without explicit human confirmation
- Never silently skip a failed story-writer — retry once, then surface the skipped batch

## Progress Tracking

Multi-phase skill — at session start, seed a task per flow node from `templates/skill-progress-tasks.md`. Mark each `in_progress` when entering the node, `completed` when its Exit condition fires. Use the harness's task tool (`TaskCreate` in Claude Code, equivalent elsewhere — phrasing in the template is harness-agnostic).

## Wrong-Tool Detection
- **User wants a non-engineering doc (research, UX memo, strategy)** → use `/write-spec-docs` instead
- **User wants a presentation-ready summary of an existing spec** → use `/write-spec-summary`
- **User wants an architecture document (system boundaries, ADRs, component interactions) from a finalized design** → use `/write-architecture-docs`
- **User wants to update only the engineering guide** → use `/write-engineering-guide`
- **User wants to brainstorm the spec first** → run `/synapse-brainstorm` to produce the memo this skill consumes
- **User wants to validate or regen an INDEX after writing** → run the `docs-ticket-validator` and `docs-index-builder` tools

## Entry

### [NEW] Fresh session
Load: templates/meta.yaml, templates/skill-progress-tasks.md
Do:
  1. Wrong-tool check — confirm a brainstorm memo exists at the supplied path
  2. Resolve `<initiative>` and `<epic>` (from args or memo frontmatter)
  3. Create or open `docs/<initiative>/epics/<epic>/` and seed `meta.yaml`
  4. Seed task list from templates/skill-progress-tasks.md
Don't: Start without a brainstorm memo. "I'll just sketch one inline" is not allowed — the memo is the contradiction-detected input contract.
Exit: → [E]

### [RESUME] Paused session
Load: templates/meta.yaml
Do: Read meta.yaml for position + roster + tmp-file inventory. Surviving `.tmp/fr-context/FR-NNN.md` files are the pending story-writer dispatch list.
Don't: Assume previous context — re-read meta.yaml and tmp inventory fresh every resume.
Exit:
  → [E] : was at epic update
  → [F] : was at FR decomposition
  → [G] : was at FR-roster gate
  → [S] : was mid story dispatch — pending = surviving tmp files
  → [V] : was at eng-guide regen
  → [R] : was at reviewer

## Flow

### [E] Epic update
Load: agents/docs-epic-writer.md
Brief: One sequential agent updates epic.md cross-cutting deltas + vocab.md. Declarative-only.
Do:
  1. Dispatch `docs-epic-writer` (model: sonnet) with full memo + prior epic.md / vocab.md + prior shipped FR rosters
  2. Judge: did epic.md stay declarative? Any algorithm or data-structure detail leaked in? → reject and re-dispatch
Don't:
  - Run epic-writer in parallel with anything — it's the foundation other agents read
  - Accept an epic.md that contains FR-level scope (cross-cutting work belongs in foundational FR-NNN stories, not epic body)
Exit:
  → [E] : leaked HOW content — re-dispatch
  → [F] : epic.md + vocab.md updated and declarative

### [F] FR decomposition
Load: agents/docs-fr-decomposer.md, references/tmp-context-schema.md
Brief: One sequential agent produces the FR roster + per-FR tmp context files at `.tmp/fr-context/FR-NNN.md`.
Do:
  1. Dispatch `docs-fr-decomposer` (model: sonnet) with memo + epic.md + vocab.md
  2. Judge: are FR-NNN ids monotonic, three-digit, globally unique within epic? Any retired number reused? → reject
  3. Verify each tmp file conforms to the schema (id, title, brief, depends_on, conflicts_with, touches, touches_function, AC, brainstorm slice, refs)
Don't:
  - Accept cross-phase `depends_on` or `conflicts_with` edges — protocol violation
  - Accept tmp files missing the brainstorm slice — story-writers will hallucinate to fill the gap
Exit:
  → [F] : roster malformed — re-dispatch
  → [G] : roster + tmp files written, meta.yaml updated

### [G] FR-roster gate
Brief: Human confirmation. Rubber-stamp if protocol is tight; pushback only on real concerns.
Do:
  1. Present roster summary: count, ids, titles, depends_on graph, conflicts_with edges
  2. Wait for explicit human confirmation
Don't: Proceed without explicit confirmation — silence is not consent.
Exit:
  → [F] : human rejects roster — re-decompose
  → [S] : human confirms

### [S] Story dispatch (parallel waves)
Load: agents/docs-story-writer.md, references/wave-dispatch.md
Brief: Skill orchestrates fan-out — DAG built from depends_on / conflicts_with / touches_function. Wave logic stays in the skill, never delegated.
Do:
  1. Build wave DAG from FR roster edges (algorithm in references/wave-dispatch.md)
  2. For each wave: dispatch `docs-story-writer` × N in parallel (model: sonnet) — each agent receives only its own tmp file path + epic.md + vocab.md
  3. Collect `{fr_id, status, files_written[], failures?}` from each writer
  4. On failure: retry once, then add to skip-and-report batch
  5. Verify each writer deleted its own tmp file on success
Don't:
  - Proceed to next wave with a failed FR sitting in this wave's dependency closure
  - Auto-skip without surfacing the batch to the user
  - Pass dependency story bodies to a writer — frontmatter only, per protocol
Exit:
  → [S] : wave failed — retry batch or escalate
  → [V] : all stories shipped (or skipped batch surfaced); meta.yaml updated

### [V] Eng-guide regeneration
Load: agents/docs-eng-guide-writer.md
Brief: Regenerate engineering_guide.md from `touches:` union + epic.md + vocab.md + prior eng-guide. Stable skeleton: Overview / Architecture / Modules / Contracts / Operations (+ optional sections).
Do:
  1. Compute `touches:` union from this phase's shipped stories
  2. Dispatch `docs-eng-guide-writer` (model: sonnet) with the union + epic.md + vocab.md + prior eng-guide
  3. Verify `regenerated_at: <commit-hash>` frontmatter present
  4. Verify primary content names no FRs — INDEX.md owns the FR view
Don't:
  - Pass "all stories ever" — only the touches union for this phase (token budget invariant)
  - Accept an eng-guide that names FRs in primary content
Exit:
  → [V] : skeleton or staleness signal violations — re-dispatch
  → [R] : draft ready

### [R] Eng-guide review
Load: agents/docs-eng-guide-reviewer.md
Brief: Drift-checks regenerated eng-guide against prior version. Writer reconciles ambiguous removals first; human escalation only on second failure.
Do:
  1. Dispatch `docs-eng-guide-reviewer` (model: sonnet) with new + prior eng-guide
  2. Read `{verdict: clean | reconcile | escalate, flags[]}`
Don't: Auto-accept `reconcile` — round-trip through writer first.
Exit:
  → [V] : verdict=reconcile — re-dispatch writer with flags
  → [END] : verdict=clean OR verdict=escalate after second cycle (surface escalation to user in summary)

### [END]
Do:
  1. Update meta.yaml: status → done
  2. Present summary: epic path, FR count, shipped/skipped breakdown, eng-guide path, reviewer verdict, any escalations
  3. Suggest next steps in prose: run `docs-ticket-validator`, regen INDEX.md via `docs-index-builder`, open PRs
Don't:
  - End without presenting full summary
  - Auto-route to the next skill — suggest, don't dispatch
