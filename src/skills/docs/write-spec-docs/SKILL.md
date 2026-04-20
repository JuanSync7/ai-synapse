---
name: write-spec-docs
description: Writes a formal requirements specification document for a software system or subsystem. Use when the user needs to define requirements, acceptance criteria, and traceability for a system component. Triggered by requests like "write a spec", "create requirements", "specification document".
domain: docs.spec
intent: write
tags: [spec, requirements, FR, NFR, traceability]
user-invocable: true
argument-hint: "[system/subsystem name] [optional: output path]"
---

## Wrong-Tool Detection

- **User wants a quick summary of an existing spec** → redirect to `/write-spec-summary`
- **User wants a design doc with task decomposition** → redirect to `/write-design-docs`
- **User wants to update an existing spec** → this skill writes new specs; for updates, read the existing spec first and revise

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

You are writing a formal requirements specification document. Follow the structure, formatting conventions, and quality standards below exactly.

## Progress Tracking

At the start, create a task list:

```
TaskCreate: "Gather inputs and analyze context"
TaskCreate: "Define scope and diagram architecture"
TaskCreate: "Draft requirements with acceptance criteria"
TaskCreate: "Build traceability matrix and verify"
TaskCreate: "Revision loop (if needed)"
```

Mark each `in_progress` when starting, `completed` when done.

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

## Requirement Format

### Blockquote Format (default)

Every requirement MUST use this exact format:

```markdown
> **REQ-xxx** | Priority: MUST/SHOULD/MAY
>
> **Description:** What the system shall do. Use active voice. Be specific and testable.
>
> **Rationale:** Why this requirement exists. Link to business/technical goal.
>
> **Acceptance Criteria:** How to verify conformance. Include concrete examples where possible.
```

### Example — Well-Written Requirement

> **REQ-103** | Priority: MUST
>
> **Description:** The system MUST return a structured error response within 500ms when a required upstream dependency is unavailable, including an error code, a human-readable message, and whether the condition is retryable.
>
> **Rationale:** Callers need a machine-readable signal to decide whether to retry or surface an error to the user. Without a consistent error contract, each caller implements its own timeout logic, leading to inconsistent user-facing behavior.
>
> **Acceptance Criteria:** Given a dependency returning HTTP 503, the system returns `{ "error": { "code": "DEPENDENCY_UNAVAILABLE", "message": "...", "retryable": true } }` within 500ms. Given a malformed request (missing required field), the system returns a non-retryable error with a descriptive message identifying the missing field.

### Anti-Pattern Example — What NOT to Write

> **REQ-104** | Priority: MUST
>
> **Description:** The system MUST handle errors appropriately and provide a reasonable user experience when things go wrong.
>
> **Rationale:** Good error handling is important.
>
> **Acceptance Criteria:** Errors are handled properly.

**Problems:** Compound ("handle errors" + "user experience"), untestable language ("appropriately", "reasonable", "properly"), no concrete values, rationale doesn't explain WHY, acceptance criteria is not verifiable.

### Table Format (alternative for high-density sections)

When a section contains many short, straightforward requirements (10+), a table format MAY be used instead:

```markdown
| ID | Priority | Description | Rationale | Acceptance Criteria |
|----|----------|-------------|-----------|---------------------|
| REQ-301 | MUST | The system MUST log every failed authentication attempt with timestamp, source IP, and username | Failed login patterns are the primary signal for brute-force detection | Log entry exists within 1s of failed attempt; entry contains all three fields |
| REQ-302 | SHOULD | The system SHOULD rate-limit login attempts to 5 per minute per IP | Prevents brute-force without blocking legitimate retry | 6th attempt within 60s returns HTTP 429; 1st attempt after cooldown succeeds |
```

When using table format:
- Every column MUST be populated (no empty Rationale or Acceptance Criteria cells)
- If Rationale or Acceptance Criteria would be too long for a table cell, use the blockquote format instead
- Do NOT mix formats within the same section

## Requirement ID Conventions

### Default: REQ-xxx

- Use a numbering scheme that groups requirements by section:
  - Section 3 → REQ-1xx
  - Section 4 → REQ-2xx
  - Section 5 → REQ-3xx
  - And so on...
- Leave gaps between IDs (101, 103, 105... not 101, 102, 103, 104) to allow future insertions
- Non-functional requirements use REQ-9xx

### Alternative: Domain-Prefixed IDs

For complex systems with many requirement categories, domain-prefixed IDs MAY be used instead of REQ-xxx:

- **FR-xxx** — Functional Requirements
- **NFR-xxx** — Non-Functional Requirements
- **SC-xxx** — Security & Compliance

When using prefixed IDs:
- Group numbering by section (e.g., FR-1xx for Section 3, FR-2xx for Section 4)
- The traceability matrix MUST still list all requirements regardless of prefix
- State the ID convention explicitly in the Requirement Format section (Section 1.4)

## Quality Standards

### Requirement Anti-Patterns (avoid these)
- **Compound requirements** — "The system MUST do X and Y" should be two separate REQs
- **Untestable language** — "appropriate", "reasonable", "properly", "efficiently", "user-friendly"
- **Implementation leakage** — Specifying HOW (e.g., "use a HashMap") instead of WHAT (e.g., "lookup MUST complete in O(1) amortized time")
- **Missing boundary conditions** — Always define behavior at edges (empty input, max size, timeout, zero results)
- **Implicit requirements** — If the system must NOT do something (e.g., must not expose internal errors to users), state it explicitly

### Descriptions
- Use active voice: "The system MUST..." not "It should be that..."
- Include concrete values where applicable (thresholds, ranges, limits)

### Rationale
- Explain WHY, not WHAT (the description already covers WHAT)
- Connect to real consequences of not implementing the requirement
- Use domain-specific examples that demonstrate the impact
- Reference design principles where applicable (e.g., "Supports the fail-safe-over-fail-fast principle")

### Acceptance Criteria
- Must be verifiable — someone should be able to write a test from the acceptance criteria
- Include at least one positive case (happy path) and consider negative cases
- Use concrete examples with realistic data when possible

### ASCII Diagrams
- Use box-drawing characters for stage/component diagrams
- Show directional flow with arrows (│ ▼ ► ◄)
- Keep each box to 2-4 lines of description
- Show the full pipeline/architecture from entry to exit

### Tables
- Use for structured data: terminology, data flow summaries, thresholds, traceability
- Keep column count manageable (3-5 columns max)
- Align consistently

## Planning Stage (NON-SKIPPABLE)

Before writing any section, read all input sources and produce a `section_context_map` — a per-section record that inlines source content and pre-constructs each section agent's complete prompt. Do this before writing a single requirement.

**Why this stage exists:** A single agent writing the full spec accumulates context across all sections, causing context drift that degrades late-document quality. The `section_context_map` gives each section agent exactly the source material it needs — no more — eliminating drift.

### `section_context_map` schema

For each section, produce one entry:

```
id:             string    # unique identifier, e.g. "sec_scope", "sec_req_query"
title:          string    # section heading
wave:           int       # execution wave — sections in the same wave run in parallel
depends_on:     [id, ...] # section IDs that must be approved before this starts
model_tier:     haiku | sonnet | opus
source_content: string    # source text for THIS section only, copied verbatim from
                          # inputs — NOT a file path. Agents never read files.
prior_slots:    [id, ...] # completed section IDs whose outputs are injected into prompt
prompt:         string    # the complete prompt for the section agent, with
                          # {{slot_id}} markers for prior_slots entries
```

### write-spec-docs section dependency graph

```
Wave 1 (parallel — no dependencies):
  sec_scope    → Section 1: Scope & Definitions
                 source: problem statement, existing architecture docs, user context
  sec_overview → Section 2: System Overview (ASCII diagram + data flow table)
                 source: same as sec_scope

Wave 2 (parallel — one entry per functional domain):
  sec_req_<N>  → Section 3+: one requirement section per logical domain
                 source: scoped to each domain's relevant context only
                 depends_on: [sec_scope, sec_overview]

Wave 3:
  sec_nfr      → Non-Functional Requirements
                 source: performance, security, reliability context only
                 depends_on: [all Wave 2 IDs]

Wave 4:
  sec_matrix   → Requirements Traceability Matrix
                 source: compiled REQ-ID list from Waves 2 + 3
                 depends_on: [all Wave 2 IDs, sec_nfr]
```

### How to produce the map

1. Read all inputs the user provided (architecture docs, improvement lists, codebase).
2. For each entry in the dependency graph above, identify which portions of the source material are relevant to that section only — not the full context.
3. Copy relevant excerpts verbatim into `source_content`. Do not paraphrase.
4. Write the complete `prompt` for the section agent: include the section heading, formatting requirements from this skill (REQ-xxx blockquote format, acceptance criteria rules, etc.), the inlined `source_content`, and `{{slot_id}}` markers for any `prior_slots`.
5. Record `wave`, `depends_on`, and `model_tier`.

→ **Proceed to Execution Stage once all map entries have their `prompt` fields populated.**

---

## Execution Stage

> **NON-SKIPPABLE:** Do not write any section until the Planning Stage is complete and the `section_context_map` exists in session. If you are tempted to skip ahead because the system seems small or the sections seem obvious, resist. The map is the isolation guarantee — without it, agents receive unscoped context and context drift will degrade late sections.

Execute the `section_context_map` using **parallel-agents-dispatch** with sequential waves:

1. **Wave 1** — dispatch all Wave 1 sections in parallel. Each agent receives only its `prompt` field (source already inlined — agents never read files).
2. **Review** each section for compliance (REQ-xxx blockquote, no compound requirements, verifiable acceptance criteria) before proceeding to the next wave.
3. **Subsequent waves** — fill `{{slot_id}}` markers in each prompt with the approved prior-section output. Dispatch in parallel.
4. **Continue** wave-by-wave until all sections are approved.
5. **Assemble** — combine all approved section outputs into the final document in section order.

**Section agent isolation contract:**

> The section agent receives ONLY:
> 1. Its `prompt` from the section_context_map (source content already inlined)
> 2. Prior approved section outputs injected into `{{slot_id}}` markers
>
> Must NOT receive: the full input documents, other sections' source material, or the complete section_context_map.

Each section agent follows these steps for its assigned section:

1. **Analyze** — Review the inlined source content in the prompt
2. **Scope** — Define the boundary for this section (entry/exit points if applicable)
3. **Diagram** — For the System Overview section only: draw the pipeline/architecture
4. **Group** — Organize requirements into logical sub-groups within the section
5. **Write** — Draft each requirement with Description + Rationale + Acceptance Criteria
6. **Number** — Assign IDs using the numbering convention
7. **Trace** — Note which requirements this section contributes to the traceability matrix
8. **Count** — Tally MUST/SHOULD/MAY for the final traceability section

## Handling Revision Requests

After the user reviews a draft, they may request changes. Common patterns:

- **Scope additions** — Assign new IDs within existing ranges. If no range has room, add a new section and extend the ID scheme. Update the traceability matrix.
- **Requirement rewrites** — Rewrite the block in place, keep the original REQ-ID. If the change is substantive, note it in the version history table.
- **Structural changes** — Update the ID range table in Section 1.5 and the traceability matrix to reflect the new section mapping.
- **Scope removals** — Mark removed requirements as "REMOVED" in the traceability matrix rather than deleting them, so reviewers can see the delta.

Re-run the Before You Submit checklist after revisions.

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

- DO use domain-specific terminology (define it in the Terminology section)
- Keep the document focused on WHAT and WHY — leave HOW to the implementation document
- Use horizontal rules (`---`) between major sections for visual separation
- If the system handles sensitive data, include requirements about data protection
- Consider observability — can operators debug issues with the specified system?
- **Version history** — Include a changelog table at the top when the spec is expected to evolve across multiple iterations

## Before You Submit — Verification Checklist

Run through this before presenting the draft to the user:

- [ ] Every requirement has a Rationale and at least one Acceptance Criterion
- [ ] No compound requirements ("MUST do X and Y" — split into two REQs)
- [ ] No untestable language ("appropriate", "reasonable", "properly", "efficiently")
- [ ] Every Acceptance Criterion is verifiable — someone could write a test from it
- [ ] FR-ID ranges do not overlap with any sibling spec for the same system
- [ ] Traceability matrix lists every requirement in the document (no omissions)
- [ ] MUST/SHOULD/MAY tally at the bottom of the matrix is correct
- [ ] Out-of-scope list is explicit — includes both "out of scope for this spec" and "out of scope for this project" when relevant
- [ ] The document is standalone — no references to specific file names, class names, or function names
- [ ] If the system has failure modes, at least one requirement covers graceful degradation
- [ ] If the system has configurable parameters, at least one requirement covers configuration externalization

## Integration

**Downstream (invoke after this skill):**
- `write-spec-summary` — generate a concise digest of this spec
- `write-design` — generate a technical design document with task decomposition and contracts

**Companion skills (use hand-in-hand):**
- `superpowers:brainstorming` — if requirements aren't settled yet, brainstorm first
- `superpowers:verification-before-completion` — verify the checklist above with evidence before claiming completeness

## README Dashboard

After saving the spec, update the subsystem's `README.md` dashboard. Read [`references/readme-update-contract.md`](references/readme-update-contract.md) for the full procedure. If the README does not exist, create it.

**Chain handoff:** After saving the spec, completing the verification checklist, and updating the README:

> "Spec complete and saved to `[path]`. Next steps: `/write-spec-summary` for a concise digest, or `/write-design` to begin task decomposition. Which would you like?"

## Document Chain

```
Unphased:
write-spec-docs  →  write-spec-summary  →  write-design  →  build-plan
 _SPEC.md            _SPEC_SUMMARY.md       _DESIGN.md       _IMPLEMENTATION.md

Phased:
write-spec-docs  →  write-spec-summary  →  write-design  →  write-implementation-docs
 _SPEC_P1.md         _SPEC_SUMMARY_P1.md    _DESIGN_P1.md    _IMPLEMENTATION_DOCS_P1.md
```
