# Documentation Skills — Governance Rules

This file is the **authoritative reference** for the doc-authoring skill suite. It is NOT loaded at runtime — governance rules are inlined into each skill's `SKILL.md`. When rules change, update this file first, then propagate to each affected skill.

---

## The 4-Layer Document Hierarchy

Every system or subsystem is documented across four layers. Each layer has one owner and one role:

| Layer | Document Type | Role | Skill |
|-------|--------------|------|-------|
| 1 | Platform Spec | Platform-wide scope, cross-system contracts | (manual) |
| 2 | Spec Summary | Distilled view; §1 is tech-agnostic and scrapeable | `write-spec-summary` |
| 3 | Authoritative Spec | Full FR/NFR requirements with traceability | `write-spec` |
| 4 | Implementation Guide | Phased tasks, code appendix, HOW to build | `write-impl` |

### Layer Rules

- **Never skip layers.** A summary (Layer 2) requires a spec (Layer 3). An implementation guide (Layer 4) requires a spec (Layer 3).
- **Changes propagate downward.** When a spec changes, its summary and implementation guide must be reviewed and updated.
- **Sibling specs must not overlap.** When one spec is split into two, FR-ID ranges must be non-overlapping and mutually exclusive.
- **Layer 2 §1 is always tech-agnostic.** The Generic System Overview in every spec summary must contain no FR-IDs, no technology names, no implementation file names. It is designed to be scraped and assembled into a platform-level overview document.

---

## Cross-Skill Coherence Gates

Run these checks before finalizing any document.

### Before finalizing a Spec Summary (Layer 2)

- [ ] The companion spec (Layer 3) exists and was fully read
- [ ] §1 Generic System Overview contains no FR-IDs, no technology names, no implementation file names
- [ ] §1 covers all five dimensions: purpose, pipeline flow, tunable knobs, design rationale, boundary semantics
- [ ] §2+ scope lists match the spec exactly (no added or removed items)
- [ ] No specific threshold values or metric targets appear outside the spec

### Before finalizing an Authoritative Spec (Layer 3)

- [ ] FR-ID ranges do not overlap with any sibling spec for the same system
- [ ] Every requirement has a Rationale and Acceptance Criteria
- [ ] Design principles are defined where cross-cutting concerns apply
- [ ] Out-of-scope list is explicit and complete

### Before finalizing an Implementation Guide (Layer 4)

- [ ] The companion spec (Layer 3) exists and was fully read
- [ ] Every task traces to at least one spec requirement
- [ ] Every spec requirement is covered by at least one task
- [ ] Task dependency graph is a valid DAG (no circular dependencies)
- [ ] Critical path is identified

---

## The §1 Generic System Overview Contract

§1 of every spec summary is a technology-agnostic, fully-detailed description of the system. It is written from scratch by Claude based on the spec's functional content — not copied or condensed from the spec.

### What §1 Must Cover (five dimensions)

1. **Purpose** — What problem this system solves. What role it plays in the larger platform. Why it exists.
2. **Pipeline flow** — How input moves through the system, described generically. Stage names describe WHAT, not HOW (e.g., "text extraction stage", not "PyMuPDF extraction"). Include conditional/optional paths.
3. **Tunable knobs** — What operators and engineers can configure to change system behaviour. For each configurable dimension: what it controls, why someone would adjust it, what happens with default settings.
4. **Design rationale** — Why the system is designed this way. What constraints or principles drove the key architectural decisions. What alternatives were implicitly rejected.
5. **Boundary semantics** — Entry point: what triggers the system. Exit point: what it produces. What is handed off vs. discarded at each boundary.

### What §1 Must NOT Contain

- Requirement IDs of any kind (FR-xxx, NFR-xxx, SC-xxx, REQ-xxx)
- Specific technology names (no "LangGraph", "Qdrant", "GPT-4o", "PyMuPDF", "FastAPI", etc.)
- Implementation file names or class names
- Specific threshold values, metric targets, or SLA numbers
- Project-specific jargon that only makes sense inside this codebase

### Length and Purpose

- **Target:** 250–450 words. Full detail — not condensed like the rest of the summary.
- **Purpose:** This section is extracted by a script to assemble a top-level platform overview. Keep the section boundary clean: content starts immediately after the `## 1)` heading and ends before the `---` rule. Do not use sub-headings that cross the boundary.
- **Sub-headings:** Use `###` sub-headings for each of the five dimensions. This makes script extraction and human scanning predictable.
