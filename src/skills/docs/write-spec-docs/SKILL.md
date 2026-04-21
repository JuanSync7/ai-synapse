---
name: write-spec-docs
description: "Writes or updates a formal requirements specification document for a software system or subsystem. Use when the user needs to define requirements, acceptance criteria, and traceability for a system component. Triggered by requests like 'write a spec', 'create requirements', 'specification document', or 'update this spec'."
domain: docs.spec
intent: write
tags: [spec, requirements, FR, NFR, traceability, orchestration]
user-invocable: true
argument-hint: "[system/subsystem name] [optional: output path]"
---

## Wrong-Tool Detection

- **User wants a quick summary of an existing spec** → redirect to `/write-spec-summary`
- **User wants a design doc with task decomposition** → redirect to `/write-design-docs`
- **User wants a surgical update to a specific section from a git diff** → redirect to `/patch-docs`
- **User wants to update an existing spec with structural changes** → this skill in update mode

## Layer Context

This skill produces a **Layer 3 — Authoritative Spec** in the 5-layer doc hierarchy:

```
Layer 1: Platform Spec          (manual)
Layer 2: Spec Summary           ← write-spec-summary
Layer 3: Authoritative Spec     ← YOU ARE HERE
Layer 4: Design Document        ← write-design
Layer 5: Implementation Plan    ← build-plan
```

**Before writing, verify:**
- FR-ID ranges do not overlap with any sibling spec for the same system
- Design principles are defined if cross-cutting concerns apply across multiple requirements
- Out-of-scope list is explicit — include both "out of scope for this spec" and "out of scope for this project" when the distinction matters

**After writing, these companion documents need to be created or updated:**
- Layer 2 Spec Summary → `/write-spec-summary`
- Layer 4 Implementation Guide → `/write-impl`

---

# Specification Document Skill

You are the **planner** — you orchestrate spec writing by constructing section briefs, dispatching writer and reviewer agents, propagating discoveries between sections, and maintaining file-based working memory. You never write spec content directly.

## Input Gathering

Before writing, you MUST understand the system being specified. If the user has not provided sufficient context, gather information in priority order:

**Essential — always clarify if not provided:**
1. **Scope boundary** — What is the entry point and exit point of the system/subsystem?
2. **Problem statement** — What problem does this system solve? Why do existing solutions fail?
3. **Key terminology** — What domain-specific terms need formal definitions?

**Important — ask when relevant to the system:**
4. **Existing architecture** — Is there an architecture document, design doc, or codebase to reference?
5. **Known gaps/improvements** — Are there existing improvement lists, bug reports, or feature requests?
6. **Assumptions & constraints** — What does the spec take for granted? (e.g., runtime environment, available infrastructure, external service SLAs)

**Conditional — ask only when the system clearly needs them:**
7. **Priority framework** — Default is RFC 2119 (MUST/SHOULD/MAY). Only ask if a different scheme is needed.
8. **Design principles** — Cross-cutting concerns that guide multiple requirements (e.g., fail-safe over fail-fast).
9. **External interfaces** — APIs, message queues, file formats, or protocols that need formal contracts.
10. **External dependencies** — Services, models, or infrastructure the system depends on. Which are required vs optional?
11. **Delivery phasing** — Will this be delivered in multiple phases? If so, which phase is being specified?
12. **Prior phase specs** — For P2+: paths to prior phase spec documents (required for carry-forward)
13. **Companion documents** — Related documents that should be cross-referenced.

Many of these questions can be inferred from context. Before asking, check whether the user has provided architecture documents, a codebase to read, a conversation history, or an existing improvement list. Ask only for information that cannot be reasonably inferred. When in doubt, state your inference explicitly ("I'm treating the entry point as X — correct me if wrong") rather than asking.

If the user provides `$ARGUMENTS`, treat the first argument as the system/subsystem name and the second (if provided) as the output file path.

## Document Structure

The specification MUST follow the structure defined in [template.md](template.md). Adapt section names and content to the specific domain, but preserve the hierarchy:

1. **Scope & Definitions** — Problem statement, boundary (entry/exit points), terminology, priority levels, requirement format, assumptions & constraints, design principles, out of scope
2. **System Overview** — ASCII architecture diagram + data flow summary table
3. **Requirement Sections (one per component/stage)** — Grouped by logical stage
4. **Conditional Sections** — Interface contracts, error taxonomy, data model, state & lifecycle, evaluation framework, external dependencies
5. **Non-Functional Requirements** — Performance, scalability, reliability, maintainability, security, deployment
6. **System-Level Acceptance Criteria** — Cross-cutting quality thresholds
7. **Requirements Traceability Matrix** — Full listing with MUST/SHOULD/MAY tally
8. **Appendices** — Glossary, document references, implementation phasing, open questions

Read the template file before writing to ensure exact formatting compliance.

## Quality Standards

Use these when constructing section briefs. You decide what goes in each brief; the writer agent enforces the format rules.

### Requirement Format

Every requirement MUST have three fields — the writer agent enforces this, but the planner needs to know what they are for brief construction:

- **Description** — Active voice ("The system MUST..."), concrete values where applicable
- **Rationale** — Why this requirement exists (not a restatement of the description)
- **Acceptance Criteria** — Verifiable conditions with thresholds, observable behaviors, or testable outcomes

### Requirement Anti-Patterns (avoid these in briefs)
- **Compound requirements** — "The system MUST do X and Y" should be two separate REQs
- **Untestable language** — "appropriate", "reasonable", "properly", "efficiently", "user-friendly"
- **Implementation leakage** — Specifying HOW (e.g., "use a HashMap") instead of WHAT (e.g., "lookup MUST complete in O(1) amortized time")
- **Missing boundary conditions** — Always define behavior at edges (empty input, max size, timeout, zero results)
- **Implicit requirements** — If the system must NOT do something, state it explicitly

### ASCII Diagrams
- Use box-drawing characters for stage/component diagrams
- Show directional flow with arrows (│ ▼ ► ◄)
- Keep each box to 2-4 lines of description
- Show the full pipeline/architecture from entry to exit

### Tables
- Use for structured data: terminology, data flow summaries, thresholds, traceability
- Keep column count manageable (3-5 columns max)
- Align consistently

---

## Orchestration Model

You are the planner. All state lives in files. Every decision, every brief, every signal — externalized to disk so the workflow survives auto-compaction. You plan, you dispatch, you integrate. You never write spec content directly.

> This skill follows the [external-memory protocol](../../protocols/external-memory/external-memory.md). Read it if this is your first time orchestrating with file-based memory.

### Memory Files

| File | Type | Purpose |
|------|------|---------|
| Planning notepad | **Ephemeral** | Section briefs, signals log, decisions, rejected briefs. Initialized from [templates/notepad.md](templates/notepad.md). Discarded after run. |
| Document map (`_SPEC_MAP.md`) | **Persistent** | Skeleton + sections table + entity index + REQ index. Initialized from [templates/spec-map.md](templates/spec-map.md). Lives alongside the spec. |

**Rules:** Read memory before every planning decision. Write memory after every significant action. Subagents return signals to you — they never write to these files.

### Mode Detection

Detect mode before initializing memory:

- **Create mode:** No existing spec file at the target path. Start from scratch.
- **Update mode:** Existing spec file AND existing `_SPEC_MAP.md` found. Brief includes `change_reason` and affected sections. Used by `/patch-docs` for structural changes.

Without explicit mode detection, create mode overwrites existing specs and update mode tries to create skeletons that already exist.

### Create Mode Flow

1. **Read inputs** — all source material the user provided (architecture docs, improvement lists, codebase). Read [template.md](template.md).
2. **Create spec skeleton** — write the spec file with all section headings and `<!-- sec:id -->` / `<!-- /sec:id -->` anchor pairs. No content yet — just the skeleton.
3. **Create doc map** — initialize `_SPEC_MAP.md` from [templates/spec-map.md](templates/spec-map.md). Fill in the skeleton table with actual section headings and anchors.
4. **Create notepad** — initialize from [templates/notepad.md](templates/notepad.md). Fill in paths and document skeleton.
5. **Produce section briefs** — for each section, construct a brief in the notepad. You may iterate freely — revise briefs, reorder, adjust depth and model assignment. This is your reasoning space.
6. **Per-section dispatch loop** — process sections sequentially (see below).
7. **Coherence review** — dispatch the coherence reviewer on the full doc (see below).
8. **Finalization** — surface NEEDS_MANUAL items, update README dashboard.

### Update Mode Flow

1. **Read existing spec + doc map** — these are your base. Do not create a skeleton.
2. **Identify affected sections** — from the change context (user request or `/patch-docs` escalation), determine which sections need updating.
3. **Create notepad** — initialize from template, but only produce briefs for affected sections. Each brief gets `change_reason` and `delta` fields in addition to standard fields.
4. **Per-section dispatch loop** — same as create mode, but writer operates in update prompt mode.
5. **Coherence review** — on the full doc (changes may affect coherence beyond updated sections).
6. **Finalization** — same as create mode.

### Per-Section Dispatch Loop

Process sections **sequentially** — each section's output may inform the next section's brief. This is the core quality guarantee: isolated context per section, discoveries propagated forward. You never write spec content directly — every section goes through the writer agent.

For each section in the notepad:

1. **Finalize the brief.** Read the notepad. Check if signals from previous sections affect this brief. Revise if needed. Write the updated brief back to the notepad.
2. **Dispatch the writer.** Use the `docs-spec-section-writer` agent. Pass:
   - The finalized brief (from notepad)
   - The spec file path
   - The doc map file path
   - The model assignment from the brief (`model` field)
3. **Read the writer's sidecar.** Extract signals (new entities, cross-refs, assumptions).
4. **Dispatch the section reviewer.** Use the `docs-spec-section-reviewer` agent (Sonnet). Pass:
   - The brief
   - The spec file path + section anchor (so the reviewer can read the written section)
   - The full writer sidecar
5. **Handle the verdict:**
   - **PASS:** Update the doc map (section status, entity index, REQ index). Log signals to notepad. Scan all remaining briefs for cross-ref impact — revise any that reference entities discovered in this section.
   - **PASS-with-note:** Same as PASS, plus log the reviewer's notes for consideration in upcoming briefs.
   - **REJECT:** Read the reject reasoning. Revise the brief in the notepad (record the old brief in Rejected Briefs). Re-dispatch writer + reviewer **once**. If still rejected → mark as NEEDS_MANUAL with the specific rejection reason.
6. **Update notepad** — set section status, append to signals log and decisions.
7. **Proceed to next section.**

### Coherence Review

After all sections complete the per-section loop:

1. **Dispatch the coherence reviewer.** Use the `docs-spec-coherence-reviewer` agent (Sonnet). Pass:
   - The spec file path
   - The doc map file path
2. **Handle the verdict:**
   - **PASS:** Proceed to finalization.
   - **REJECT:** Read the per-section rejection table. For each rejected section, re-enter the per-section dispatch loop in update mode (writer gets `change_reason` from the rejection). Run coherence review **once more** after all fixes. If still failing → fail loudly with a summary table of unresolved issues.

### Brief Construction

Each brief in the notepad follows the format defined in [templates/notepad.md](templates/notepad.md). The writer validates that `heading` is non-empty, `key_points` has 2+ items, `depth` is one of standard/deep/overview, and `source_excerpts` has 1+ item.

**Concrete example** — a brief for an authentication requirement section:

```
### sec:req_auth
- status: pending
- model: sonnet
- heading: Authentication Requirements
- key_points:
  - OAuth2 PKCE flow for web and mobile — separate token endpoints per client type
  - Refresh token rotation with configurable TTL, revocation on reuse detection
- cross_refs:
  - entity: session_token | defined_in: sec:scope | usage: auth tokens stored per session model
- source_excerpts:
  - "Rate limit at 100 req/s per tenant, graceful degradation when the identity provider is unavailable"
- tools_hint: Explore agent for existing auth middleware interfaces
- depth: deep
- retry_count: 0
```

**References vs. inline:** For entities that already exist in a written section, use `cross_refs` to point to the doc map entry — don't inline the content. For new entities being defined in this section, provide the detail in `source_excerpts`. Without this distinction, briefs either bloat with duplicated content or starve writers of needed context.

**Update mode briefs** add `change_reason` and `delta` fields (see notepad template for full format).

### NEEDS_MANUAL Surfacing

When a section hits max retries (1 per section, 1 coherence re-pass) and cannot be resolved:

- Mark the section as `needs-manual` in the notepad
- Surface to the user with **specific, answerable questions** — not "this section needs work" but "Section 4 REQ-203 has a compound requirement that I couldn't split because both behaviors share the same acceptance criteria — should these be separate requirements with shared criteria, or one requirement?"
- Continue processing remaining sections — do not halt the pipeline

### Model Policy

- **Planner (you):** Uses whatever model the user invoked with
- **Writer:** Model per brief — default Sonnet, escalate to Opus for complex sections (deep depth, high cross-ref count, domain expertise needed)
- **Section reviewer:** Always Sonnet
- **Coherence reviewer:** Always Sonnet

### Retry Policy

- **Per-section:** Max 1 retry. After revision + re-dispatch, if still rejected → NEEDS_MANUAL.
- **Coherence:** Max 1 re-pass after fixing rejected sections. If still failing → fail loudly with summary table.
- **Failure tags:** All agents use the [failure-reporting protocol](../../protocols/failure-reporting/failure-reporting.md). Accumulate failures, continue through all sections, surface complete summary at the end.

---

## Progress Tracking

At the start of spec writing, create tasks to track the workflow:

```
TaskCreate: "Create spec skeleton and doc map"
TaskCreate: "Produce section briefs in notepad"
TaskCreate: "Dispatch and review sections sequentially"
TaskCreate: "Run coherence review"
TaskCreate: "Finalize — surface NEEDS_MANUAL items, update README"
```

Mark each `in_progress` when starting and `completed` when done. When dispatching writer and reviewer agents, set `model:` explicitly on every Agent call (per the Model Policy).

---

## Phased Delivery

When writing a spec for a specific delivery phase (P1, P2, P3...) rather than a monolithic spec:

> **Read [`references/phased-delivery.md`](references/phased-delivery.md)** for the full phasing rules: FR-ID range allocation, carry-forward requirements, scope boundary conventions, and cross-phase dependency tracking.

**Summary:**
- Output naming: `{SUBSYSTEM}_SPEC_P{N}.md`
- FR-ID ranges: P1 gets FR-100–199, P2 gets FR-200–299, etc.
- P2+ specs must include a "Prior Phase Contracts" section listing interfaces this phase depends on
- P2+ specs must include a "Cross-Phase Dependencies" appendix
- After writing, update the subsystem README dashboard — read [`references/readme-update-contract.md`](references/readme-update-contract.md)

## Conditional and Appendix Sections

The template includes optional sections for Interface Contracts, Error Taxonomy, Data Model, State & Lifecycle, Evaluation Framework, External Dependencies, Feedback loop, Glossary, Document References, Implementation Phasing, and Open Questions.

**Include or omit each section based on the criteria in [template.md](template.md).** The template comments describe exactly when each section applies.

## Additional Guidelines

- Use domain-specific terminology (define it in the Terminology section)
- Keep the document focused on WHAT and WHY — leave HOW to the implementation document
- Use horizontal rules (`---`) between major sections for visual separation
- If the system handles sensitive data, include requirements about data protection
- Consider observability — can operators debug issues with the specified system?
- **Version history** — Include a changelog table at the top when the spec is expected to evolve across multiple iterations

## Integration

**Downstream (invoke after this skill):**
- `write-spec-summary` — generate a concise digest of this spec
- `write-design` — generate a technical design document with task decomposition and contracts

## README Dashboard

After saving the spec, update the subsystem's `README.md` dashboard. Read [`references/readme-update-contract.md`](references/readme-update-contract.md) for the full procedure. If the README does not exist, create it.

**Chain handoff:** After saving the spec, completing the coherence review, and updating the README:

> "Spec complete and saved to `[path]`. Companion map at `[map_path]`. Next steps: `/write-spec-summary` for a concise digest, or `/write-design` to begin task decomposition. Which would you like?"

## Document Chain

```
Unphased:
write-spec-docs  →  write-spec-summary  →  write-design  →  build-plan
 _SPEC.md            _SPEC_SUMMARY.md       _DESIGN.md       _IMPLEMENTATION.md
 _SPEC_MAP.md

Phased:
write-spec-docs  →  write-spec-summary  →  write-design  →  write-implementation-docs
 _SPEC_P1.md         _SPEC_SUMMARY_P1.md    _DESIGN_P1.md    _IMPLEMENTATION_DOCS_P1.md
 _SPEC_MAP_P1.md
```
