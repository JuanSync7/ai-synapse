---
name: autonomous-orchestrator
description: Use when you want to build a feature end-to-end autonomously — from brainstorming through specs, design, code, and documentation with review at every step. Triggered by "build autonomously", "overnight pipeline", "run the full pipeline", "build this overnight".
domain: synapse
intent: execute
tags: [pipeline, autonomous, end-to-end]
user-invocable: true
argument-hint: "[goal or path to brief.yaml] [--template full|feature|bugfix|docs-only] [--stages stage1,stage2,...] [--from <stage> [<path>]]"
---

# Autonomous Orchestrator

Fully autonomous development pipeline. Takes a goal (free text or structured brief), orchestrates existing skills through brainstorming → specs → design → implementation → docs, with stakeholder-reviewer gating every transition. Human only sees ESCALATEs.

**Announce at start:** "I'm using the autonomous-orchestrator to run the `<template>` pipeline autonomously." — substitute the actual template name (e.g., "full", "bugfix", "docs-only"). If `--stages` was used instead of a template, say "a custom pipeline" instead of the template name.

## Progress Tracking

At the start, create a task list for each pipeline stage so the user sees progress:

```
TaskCreate: "Phase 0: Initialize run directory and parse input"
TaskCreate: "Phase 1: Brainstorm — context, approaches, design sketch"
TaskCreate: "Gate: Brainstorm → stakeholder review"
TaskCreate: "Phase 2: Spec — write formal requirements"
TaskCreate: "Gate: Spec → stakeholder review"
TaskCreate: "Phase 3: Design — task decomposition and contracts"
TaskCreate: "Gate: Design → stakeholder review"
TaskCreate: "Phase 4: Implementation — execute plan"
TaskCreate: "Gate: Implementation → stakeholder review"
TaskCreate: "Phase 5: Engineering guide — document what was built"
TaskCreate: "Gate: Eng guide → stakeholder review"
```

Adjust the list based on the actual template/stages selected. Mark each `in_progress` when starting, `completed` when done. Skip tasks for stages not in the pipeline.

When dispatching subagents (stakeholder-reviewer, skill invocations), set `model:` explicitly so the user sees which model is being used (e.g., `Agent (...) opus`).

## Core Principles

1. **Agent is the expert** — make decisions, explain reasoning, show alternatives
2. **Smell test every decision** — challenge assumptions, probe alternatives, question the obvious choice. Ask: "does this feel over-engineered? under-explored? is there a simpler version?"
3. **Stakeholder-reviewer gates every transition** — iterative APPROVE/REVISE/ESCALATE loop
4. **ESCALATE = queue and branch** — provisional decision, tag downstream, keep going
5. **Checkpoint persistence** — crash-resilient. Resume from last completed gate.
6. **Pipeline is a swappable port** — hierarchical skill registry now, LangGraph later

## Input Parsing

**Mid-pipeline injection:** The orchestrator can inject an existing artifact as a completed stage and start from the next stage. Activates two ways:

1. **Explicit flag:** `--from <stage> [<path>]`
2. **Auto-detected:** no `--from` given AND invocation contains "take over" / "run with this" / "continue" / no goal at all

In both cases, if no `<path>` is provided, scan the conversation for the most complete matching artifact (priority: impl > design > spec > brainstorm):

| Conversation contains | Stage | Runs next |
|---|---|---|
| Implementation plan, phased tasks, code contracts | `impl` | `code` |
| Technical design, task decomposition | `design` | `impl` or `code` |
| Formal spec, requirements, FR/NFR list | `spec` | `design` |
| Design sketch, approach + components | `brainstorm` | `spec` |

Surface the match: *"I found a [stage] artifact — [first 10 lines]. Confirm to proceed or say 'start fresh'."* On confirmation, write to `.autonomous/runs/<run-id>/<stage>-injected.md`. If nothing found and no goal, ask what to build.

If `<path>` is given, verify it exists and is non-empty. Phase 0 seeds `state.yaml`: stages before `<stage>` → `skipped`; `<stage>` → `completed`, `verdict: INJECTED`; rest → `pending`.

Accept either free text or a structured brief file.

**Free text:** Parse the argument as the goal. Use `full` template unless `--template` or `--stages` is specified.

**Router:** When no `--template` or `--stages` is specified, the router assembles the pipeline dynamically from `SKILLS_REGISTRY.yaml`. See **Router Algorithm** section below. `--template <name>` selects a named preset directly (fast path, skips traversal).

**Structured brief:** If the argument is a file path ending in `.yaml` or `.yml`, read it as a brief.

> **Read [`brief-template.md`](brief-template.md)** when parsing a structured brief input.

**Precedence:** `--stages` overrides `--template` overrides template inference. If nothing matches, default to `full`.

**Validation:** If `--stages` is provided, run Steps 5–6 of the Router Algorithm (dependency resolution + type validation) against the explicit stage list. Do not run traversal (Steps 2–4). If dependency resolution adds stages the user did not list, surface the additions and ask for confirmation.

**Special case — `docs-only` template:** The `eng-guide` stage normally receives implemented source files from `code`. In `docs-only` (no `code` stage), `eng-guide` receives spec/spec-summary output and writes a prospective engineering guide based on the specification — documenting architecture and decisions as designed, not as built.

## Pipeline Execution

### Phase 0: Initialize

1. **Load registry** — Read `synapse/SKILLS_REGISTRY.yaml` (or `.claude/skills/SKILLS_REGISTRY.yaml` if installed). Reject if `version` is missing or not `2`. Scan plugin directories for `REGISTRY_ENTRY.yaml` files; merge into the in-memory tree (in-memory only — never written back). On `stage_name` collision between plugins or with core registry, reject the colliding plugin entry and surface the conflict to the user.
2. **Assemble pipeline** — Run the Router Algorithm (see below) to determine the stage sequence for this run.
3. **Parse input** — goal + `--from` if present.
4. **Generate run-id** — `<YYYY-MM-DD>-<topic-slug>` where topic-slug is 2-4 lowercase hyphenated words derived from the goal.
5. **Create run directory** — `.autonomous/runs/<run-id>/`
6. **Write initial `state.yaml`** — apply mid-pipeline injection rules from Input Parsing if triggered; otherwise set all stages to `pending`.
7. **Read stakeholder persona** — global + project-level.

> **Read [`stage-interface.md`](stage-interface.md)** for field semantic definitions (input_from, output_path, context_type allowlist).
> **Read [`pipeline-templates.md`](pipeline-templates.md)** for fallback rules and inter-stage contracts.

### Phase 1: Brainstorm

The brainstorm stage is built-in (no external skill to invoke), but it is still dispatched as a subagent for context isolation.

**Dispatch as subagent:** Set brainstorm status to `in_progress` in `state.yaml`, then dispatch a subagent with the goal text and a reference to `brainstorm-phase.md`.

> **Read [`brainstorm-phase.md`](brainstorm-phase.md)** — include in the subagent dispatch prompt.

The brainstorm subagent:
1. **Context gathering** — read README, codebase summaries, docs, persona, parse goal
2. **Exploration** — generate clarifying questions, self-answer from context, smell test each answer. Produce 2-3 approaches with recommendation + devil's advocate for each rejected option. Gate: stakeholder-reviewer with `context_type: approach_selection`.
3. **Design sketch** — write goal, chosen approach, key decisions, components, scope boundary. Gate: stakeholder-reviewer with `context_type: design_approval`.

Output: design sketch markdown saved to `docs/superpowers/specs/<date>-<topic>-sketch.md`

**After subagent returns:** Record the output file path in `state.yaml` under `brainstorm.output`, set status to `completed`.

### Phase 2: Execute Remaining Stages

**Critical: subagent isolation.** Every stage MUST be dispatched as its own subagent — including brainstorm (Phase 1). The main orchestrator is a pure dispatcher: it manages `state.yaml`, passes file paths, and records verdicts. It never reads or carries full document content.

> **Read [`subagent-contract.md`](subagent-contract.md)** — include its contents in every subagent dispatch prompt so the subagent knows its responsibilities (input reading, revision loop, task cleanup, return format).

For each remaining stage in the template (in order):

1. **Update state** — set stage to `in_progress` in `state.yaml`
2. **Prepare input** — identify the output path from the stage's `input_from` predecessor. If predecessor was skipped, use the most recent available artifact. Pass the **path**, not the content.
3. **Dispatch subagent** — launch a subagent (Agent tool, set `model:` explicitly) with the skill name, input path, stage context_type, and the subagent contract. The subagent handles everything: skill invocation, self-critique, stakeholder-reviewer gate, revision loops, and task cleanup.
4. **Record and checkpoint** — when the subagent returns `{output_path, verdict, iterations}`, record in `state.yaml` under `<stage>.output`, update status to `completed`. Verify that every `completed` stage has a non-null `output` path pointing to an existing, non-empty file.
5. **Handle escalation** — if verdict is `ESCALATE`, handle per escalation protocol before proceeding.

### Gate Logic

```
Stage output → Self-critique → Stakeholder-reviewer
  → APPROVE → next stage
  → REVISE (+ FEEDBACK) → stage fixes → re-gate (max 3)
  → ESCALATE → provisional branch → next stage
```

**REVISE bound:** 3 consecutive REVISE verdicts without APPROVE → escalate to human.

**Failure handling:** Stage throws error → status `failed` → pipeline pauses → on resume, retry from scratch. 2 consecutive failures → escalate to human.

> **Read [`escalation-handler.md`](escalation-handler.md)** when handling an ESCALATE verdict or presenting results to human.

## Router Algorithm

Assembles the pipeline stage sequence from the goal. Runs during Phase 0 Step 2.

### Step 1 — Preset check (fast path)

Check whether the goal maps to a named preset using LLM judgment (not keyword matching alone):
- Strong fix/defect signal with no new-feature scope → `bugfix`
- Documentation intent with no implementation scope → `docs-only`

If matched, present to user: *"This looks like a `bugfix` pipeline: `brainstorm → design → code`. Proceed or customize?"*

**On preset confirmation: use the preset stage list as-is. Skip Steps 2–6 entirely.** Presets are trusted sequences — dependency resolution and type validation are skipped. If the user customizes (drops/adds stages), exit fast path and validate the custom list through Steps 5–6 only.

If goal is ambiguous, fall through to Step 2.

### Step 2 — Domain traversal (slow path)

Load only top-level `name` + `summary` fields from the registry. Reason over the goal: which domains are relevant?

The `meta` domain is a **hard filter** — never selected regardless of goal. `meta` skills are internal infrastructure. A goal like "build me a new skill" redirects to `skill-creator` directly rather than running through the pipeline router.

### Step 3 — Group drill-down

For each selected domain, load its children's `name` + `summary` fields. Select relevant groups.

### Step 4 — Skill selection

For each selected group, load individual skill entries (`name` + `description` + `pipeline:` block only — not full SKILL.md). Select pipeline-routable skills (those with a `pipeline:` block) based on goal relevance.

**Empty selection:** If Steps 2–4 produce zero pipeline-routable skills, inform the user that no matching stages were found and offer to fall back to a preset or accept a custom `--stages` list.

### Step 5 — Dependency resolution

**Cycle detection:** Before resolving, build the full dependency graph and check for cycles. If a cycle is detected, surface the cycle path and abort with an error.

Resolve missing dependencies:
- For `requires_all`: add all listed stages not yet selected.
- For `requires_any`: if none of the listed stages are selected, add the leftmost one only.
- A stage appearing in both `requires_all` and `requires_any` is satisfied by its `requires_all` presence.

Recurse until no new dependencies are added. Topological sort — tie-breaking by declaration order in the YAML (top-to-bottom).

**Example:**
```
selected:  [design, code, eng-guide]

round 1:
  design.requires_all=[spec]                  → add spec
  code.requires_any=[impl, design]            → design already selected, no-op
  eng-guide.requires_any=[code, spec-summary] → code already selected, no-op

round 2:
  spec.requires_all=[brainstorm]              → brainstorm is a built_in, add it

round 3: no new additions

sort: brainstorm → spec → design → code → eng-guide
```

### Step 6 — Type validation

For each stage in the sorted sequence, find its **feeding stage**: the most recently completed stage whose `output_type` matches any type in this stage's `input_type` (per the requires graph, not necessarily the immediately preceding position). On mismatch where no predecessor produces a matching type, surface a warning and ask for confirmation.

### Step 7 — Present and confirm

```
Assembled pipeline for "add Redis caching":
  brainstorm → spec → design → impl → code → eng-guide

Matches preset `feature`. Proceed, or adjust stages?
```

User can drop stages, add stages, or confirm. `--stages` bypasses the router entirely; the explicit list goes through Steps 5–6 only. Both the Validation block in Input Parsing and this Step 7 use Steps 5–6 for `--stages` — they are consistent.

## Context Management

**The main orchestrator must compact aggressively.** Long pipelines (5+ stages) accumulate context fast — subagent results, state updates, gate verdicts, and checkpoint writes all add up.

**Compaction rules:**
1. **After every completed stage gate**, check context usage. If above **60k tokens**, run `/compact` before dispatching the next stage's subagent.
2. **Never carry full document content** in the main orchestrator context. Subagent isolation (Phase 2) prevents this by design — but if any stage ran inline (e.g., brainstorm), compact immediately after its gate.
3. **Before dispatching any subagent**, verify context is under 70k tokens. If above, compact first. A subagent dispatch at high context risks the main orchestrator running out before the subagent returns.

**Why 60-70k, not 100k:** A prior run (docling-chunking-pipeline, 8 stages) exhausted context at ~100k threshold because spec and design stages ran inline, accumulating revision content. The 60k threshold provides headroom for gate results, checkpoint writes, and escalation handling.

## Checkpoint & Resume

State file: `.autonomous/runs/<run-id>/state.yaml`

```yaml
run_id: "2026-03-25-api-caching"
template: full
input: "add caching to the API layer"
started: "2026-03-25T22:00:00Z"
provisional_decisions: []
stages:
  brainstorm:
    status: completed
    output: "docs/superpowers/specs/2026-03-25-api-caching-sketch.md"
    verdict: APPROVE
    iterations: 2
    provisional: false
  spec:
    status: in_progress
    output: null
    verdict: null
    iterations: 1
    provisional: false
  design:
    status: pending
    output: null
    verdict: null
    iterations: 0
    provisional: false
```

**Resume:** On new session, check `.autonomous/runs/` for incomplete runs. If found, present summary and offer to resume. Resume from first non-completed stage.

## Wrong-Tool Detection

- **User wants interactive, back-and-forth brainstorming** ("let's discuss", "brainstorm with you", "react in real time") → redirect to `/superpowers:brainstorming`
- **User wants a single artifact with no pipeline** ("just write me a spec", "only a design", "nothing else") → redirect to the relevant direct skill (e.g., `/write-spec-docs`)

## Coexistence

- `superpowers:brainstorming` remains available for hands-on, human-in-the-loop mode
- This skill is the default for autonomous development
- User explicitly invokes `superpowers:brainstorming` when they want direct control

## Pipeline Evolution

```
v1:  Predefined templates + flat stage list          [done]
v2:  Hierarchical skill registry + dynamic router    [current]
v3:  LangGraph — each stage is a node, orchestrator becomes a subgraph
```
