# Design Document — synapse-skill-signal-reviewer

> Brainstorm slug: `2026-05-05-synapse-skill-signal-reviewer`
> Status: **complete** | Artifact: agent (creation) | Target: `synapse/agents/synapse/skill/`

---

## 1. Problem Statement

Skill creation in ai-synapse has no quality gate between draft and eval generation. The `synapse-creator` flow-skill moves a skill from `[draft]` to `[EVAL]` without verifying that the skill is structurally sound or well-designed. This produces two downstream problems:

1. `write-skill-eval` receives poorly structured SKILL.md files, causing evals that test for the wrong things.
2. `/improve-skill` operates on skills with anatomy defects it was not designed to catch, wasting fix cycles on structural issues that should have been stopped earlier.
3. The existing `synapse-protocol-signal-reviewer` pattern shows that a review gate before eval generation is effective, but the protocol version is binary — which produces false failures for the higher-variance skill surface (SKILL.md + references/ + templates/).

What changes: a multi-dimensional review gate (`synapse-skill-signal-reviewer`) is inserted at the `[R]` phase of synapse-creator, before `write-skill-eval` is dispatched, and is also shared as a structural pre-check in `/improve-skill`.

---

## 2. Design Principles

### P1 — Graded, not binary

The protocol reviewer uses binary pass/fail for 8 checks. Skills have higher authoring variance — a binary gate would produce false failures on legitimate design trade-offs. Design quality is graded (1-5 per dimension) so the verdict can distinguish "needs work" from "fundamentally broken."

**Implication:** A separate binary anatomy gate (presence/format) still exists alongside graded design scoring. The two instruments measure different things: anatomy = is it there, design = is it good.

### P2 — Decomposed into three focused sub-agents

A single monolithic reviewer would mix structural, quality, and companion-file concerns in one prompt, degrading each judgment. The pattern established by `skill-eval-{prompter,auditor,judge}` (three focused sub-agents under a thin orchestrator) is the correct model.

**Implication:** The orchestrator (`synapse-skill-signal-reviewer`) is a thin dispatcher — it has no judgment logic of its own. All judgment lives in the three sub-agents. The orchestrator aggregates verdicts via a fixed aggregation rule.

### P3 — Spec loaded at runtime, not re-encoded inline

Re-encoding anatomy rules or design principles inside agent files creates drift risk: when CLAUDE.md or `skill-design-principles.md` changes, the reviewer becomes stale without any signal. Each sub-agent loads its authoritative spec from a canonical disk path at runtime.

**Implication:** A new canonical file `synapse/skills/skill/skill-creator/references/skill-anatomy.md` must be created to consolidate the skill anatomy spec (currently scattered across CLAUDE.md + flow-skill drafting rules). This is a side artifact of this brainstorm and a prerequisite for `synapse-skill-anatomy-reviewer` to function correctly.

### P4 — Shared across dispatchers, canonically located once

The reviewer is useful in two lifecycle moments: creation time (`synapse-creator` `[R]` phase) and improvement time (`/improve-skill` structural pre-check). It must be canonical at one location and symlinked into both consumers — not duplicated.

**Implication:** Canonical location is `synapse/agents/synapse/skill/`. Dispatchers load it by symlink; the reviewer is not aware of which dispatcher called it.

### P5 — Companion files are in scope; EVAL.md is out of scope

The skill surface includes SKILL.md + references/ + templates/. EVAL.md is out of scope: it is a generated artifact with its own lifecycle, reviewed separately by `write-skill-eval` and `synapse-gatekeeper`.

**Implication:** `synapse-skill-companion-auditor` reads references/ and templates/ but explicitly skips EVAL.md even if present.

---

## 3. Architecture

### 3.1 Flow Graph

```
[synapse-creator flow-skill: draft]
        │
        ▼
[R] synapse-skill-signal-reviewer ◄─────────────────────────────────┐
        │                                                             │
        ├─── dispatch ──► synapse-skill-anatomy-reviewer             │
        │                 (binary, SKILL.md only)                    │
        ├─── dispatch ──► synapse-skill-design-judge                 │
        │                 (graded 1-5, SKILL.md + references/ ctx)   │
        └─── dispatch ──► synapse-skill-companion-auditor            │
                          (pass/fail, references/ + templates/)      │
                                    │                                │
                          [aggregate verdicts]                       │
                                    │                                │
                          ┌─────────┴──────────┐                    │
                       APPROVE              REVISE ──────────────────┘
                          │               (max 2 cycles; cycle
                          │               tracker lives in dispatcher)
                          │                     │
                          │               ESCALATE (after cycle 2)
                          │               → surface to user
                          ▼
                      [EVAL] write-skill-eval

────────────────────────────────────────────────────────────────────
/improve-skill: structural pre-check (independent dispatch)

        │
        └─── dispatch ──► synapse-skill-signal-reviewer
                          (same canonical agent; cycle tracking
                          lives in /improve-skill dispatcher)
```

### 3.2 Node Specifications

#### synapse-skill-signal-reviewer (orchestrator)

```
Load: (none — thin dispatcher, no companion files needed)
Do:
  1. Accept skill directory path.
  2. Dispatch synapse-skill-anatomy-reviewer (model: sonnet) with path to SKILL.md.
  3. Dispatch synapse-skill-design-judge (model: sonnet) with path to SKILL.md (+ references/ for context).
  4. Dispatch synapse-skill-companion-auditor (model: sonnet) with path to skill directory.
  5. Collect all three outputs.
  6. Apply aggregation rule:
     - APPROVE iff: anatomy all pass AND design avg ≥ 3.5 AND no design dim < 2 AND companion checks ≥ 90% pass
     - REVISE: any anatomy fail OR design avg < 3.5 OR any dimension < 2 OR companion < 90%
     - ESCALATE: REVISE on second cycle (tracked by dispatcher, not orchestrator)
  7. Emit unified Signal-Strength Review report (see output schema in Memo-ready block).
Don't:
  - Do not apply judgment — only aggregate.
  - Do not track fix cycles (dispatcher responsibility).
Exit:
  - APPROVE → dispatcher proceeds to [EVAL]
  - REVISE → dispatcher fixes issues and re-dispatches
  - ESCALATE → surface to user
```

**Frontmatter:**
```yaml
domain: synapse
role: reviewer
model: sonnet
```

**Canonical location:** `synapse/agents/synapse/skill/synapse-skill-signal-reviewer.md`

---

#### synapse-skill-anatomy-reviewer (sub-agent)

```
Load: CLAUDE.md skill anatomy section + synapse-creator flow-skill drafting rules
      (via: synapse/skills/skill/skill-creator/references/skill-anatomy.md — side artifact)
Do:
  1. Read SKILL.md.
  2. For each anatomy check, emit PASS or FAIL with notes.
  3. Checks (binary, all must pass):
     a. Required frontmatter fields present (name, description, domain, intent)
     b. description is a routing contract (trigger conditions), not a workflow summary
     c. Mental-model paragraph present before mechanics
     d. Wrong-Tool Detection section present (if user-invocable: true)
     e. Progress Tracking section present (if 3+ phases)
     f. MUST/MUST-NOT sections present
  4. Return anatomy table.
Don't:
  - Do not judge design quality — only structural presence and format.
  - Do not proceed silently if skill-anatomy.md is missing; loud-fail per failure-reporting protocol.
Exit:
  - Return per-check PASS/FAIL table to orchestrator.
```

**Frontmatter:**
```yaml
domain: synapse
role: reviewer
model: sonnet
```

**Canonical location:** `synapse/agents/synapse/skill/synapse-skill-anatomy-reviewer.md`

---

#### synapse-skill-design-judge (sub-agent)

```
Load: synapse/skills/skill/skill-creator/references/skill-design-principles.md
Do:
  1. Read SKILL.md (and references/ for context only — not graded here).
  2. For each design dimension, emit score 1-5 + short rationale + fix suggestion (if score < 4).
  3. Dimensions:
     a. Mental-model-before-mechanics
     b. Policy-over-procedure
     c. Failure-mode tracing (every instruction traces to a failure)
     d. Loud failure on preconditions
     e. No bloat (every line earns its place)
     f. Description tightness (routing contract precision)
  4. Return dimension table.
Don't:
  - Do not apply binary pass/fail — only graded scores.
  - Do not grade companion files — that is companion-auditor's domain.
  - Do not proceed silently if skill-design-principles.md is missing; loud-fail.
Exit:
  - Return per-dimension score table to orchestrator.
```

**Fix threshold:** dimensions scoring < 3 require a fix suggestion (not just rationale).

**Frontmatter:**
```yaml
domain: synapse
role: judge
model: sonnet
```

**Canonical location:** `synapse/agents/synapse/skill/synapse-skill-design-judge.md`

---

#### synapse-skill-companion-auditor (sub-agent)

```
Load: progressive-disclosure rules in skill-design-principles.md
Do:
  1. Read SKILL.md + all files under references/ + all files under templates/.
  2. If 0 companion files exist: skip all per-file checks, emit "No companions — skip" (not a failure).
  3. For each companion file, check:
     a. Load trigger documented in SKILL.md (no orphans)
     b. Content not duplicated in SKILL.md body
     c. Size fits purpose (appropriate scope for companion vs inline)
     d. Templates: concrete and complete (not skeletal)
     e. References: modular (focused, not multi-concern)
  4. Return per-file PASS/FAIL table.
Don't:
  - Do not evaluate EVAL.md (out of scope).
  - Do not grade design quality — that is design-judge's domain.
  - Do not proceed silently if skill-design-principles.md is missing; loud-fail.
Exit:
  - Return per-file check table to orchestrator.
```

**Frontmatter:**
```yaml
domain: synapse
role: auditor
model: sonnet
```

**Canonical location:** `synapse/agents/synapse/skill/synapse-skill-companion-auditor.md`

### 3.3 Entry Gates

| Transition | Gate conditions |
|---|---|
| `[draft] → [R]` | SKILL.md exists at the expected path |
| `[R] → [EVAL]` | Orchestrator verdict = APPROVE |
| `REVISE → [R]` (re-dispatch) | Cycle count < 2; issues have been addressed |
| `REVISE → ESCALATE` | Cycle count = 2 (second REVISE) |

---

## 4. Output Schema

<!-- VERBATIM -->
**Frontmatter:**
```yaml
---
name: synapse-skill-signal-reviewer
description: "Signal-strength reviewer — graded multi-dimensional review of skill authoring artifacts (SKILL.md + companions) before eval generation"
domain: synapse
role: reviewer
tags: [signal-strength, skill-review, authoring-quality]
---
```

**Output schema:**
```markdown
## Signal-Strength Review — <skill-name>

### Anatomy Gate (binary, all must pass)
| # | Check | Result | Notes |
|---|-------|--------|-------|
| 1 | Frontmatter required fields | PASS/FAIL | ... |
| 2 | Description is routing contract | PASS/FAIL | ... |
| 3 | Mental-model paragraph present | PASS/FAIL | ... |
| 4 | Wrong-Tool Detection (if applicable) | PASS/FAIL | ... |
| 5 | Progress Tracking (if 3+ phases) | PASS/FAIL | ... |

### Design Quality (graded 1-5 per dimension)
| Dimension | Score | Notes |
|-----------|-------|-------|
| Mental-model-before-mechanics | 1-5 | ... |
| Policy-over-procedure | 1-5 | ... |
| Progressive disclosure | 1-5 | ... |
| Failure-mode tracing | 1-5 | ... |
| Loud failure on preconditions | 1-5 | ... |
| No bloat | 1-5 | ... |

### Companion Files
| File | Check | Result | Notes |
|------|-------|--------|-------|
| references/<name>.md | Load trigger documented | PASS/FAIL | ... |
| references/<name>.md | Not duplicated in SKILL.md | PASS/FAIL | ... |
| templates/<name>.md | Concrete, complete | PASS/FAIL | ... |

**Verdict:** APPROVE / REVISE / ESCALATE
- APPROVE: anatomy all pass + design avg ≥ 3.5 + no dimension < 2
- REVISE: any anatomy fail OR design avg < 3.5 OR any dimension < 2
- ESCALATE: REVISE on second cycle (likely design issue, not wording)
```

**Pipeline integration (synapse-creator flow-skill `[R]` phase):**
```
Load: agents/skill/synapse-skill-signal-reviewer.md
Do:
  1. Dispatch synapse-skill-signal-reviewer (model: sonnet) with skill directory path.
  2. If verdict = REVISE: fix issues, re-dispatch. Two cycles max.
  3. If verdict = ESCALATE after 2 cycles: surface to user.
Exit: APPROVE → [EVAL]
```

---

## 5. Naming Conventions

**Pattern:** `synapse-skill-<purpose>-<role>`

| Segment | Value | Source |
|---------|-------|--------|
| `synapse` | domain — framework meta-tooling | AGENT_TAXONOMY.md |
| `skill` | subdomain — scoped to skill artifacts | naming convention |
| `<purpose>` | `signal`, `anatomy`, `design`, `companion` | purpose of agent |
| `<role>` | `reviewer`, `judge`, `auditor` | AGENT_TAXONOMY.md role values |

**Directory convention (new rule):** `synapse/agents/<domain>/<subdomain>/<agent_name>.md`

All four agents land at: `synapse/agents/synapse/skill/`

**Existing inconsistency:** `synapse-protocol-signal-reviewer` is currently at `synapse/agents/protocol-review/...` (old flat pattern). Should be relocated to `synapse/agents/synapse/protocol/...` to match the new `domain/subdomain/` rule. Flagged for follow-up after this brainstorm.

---

## 6. Side Artifact — skill-anatomy.md

**File:** `synapse/skills/skill/skill-creator/references/skill-anatomy.md`

This file is a prerequisite for `synapse-skill-anatomy-reviewer` to function correctly. It does not exist yet and must be created as part of implementing the agents designed here.

**Purpose:** Single source of truth for skill anatomy spec — what a complete SKILL.md must contain, in what structure, and why. Currently scattered across:
- CLAUDE.md skill anatomy section
- synapse-creator flow-skill drafting rules

**After creation:** CLAUDE.md and flow-skill drafting rules should reference this file rather than re-stating the rules, eliminating drift.

---

## 7. Accepted Tensions

| Tension | Decision | Revisit when |
|---|---|---|
| Binary anatomy gate may still produce false failures for intentionally minimal skills | Accept — anatomy checks are presence/format only, not subjective. Minimal skills (e.g., no companions) are handled by explicit skip rules (P2: skip companion check if 0 files; P2: Wrong-Tool Detection only required if user-invocable: true). | If false failure rate is observed after 10+ skill reviews |
| Property overlap: anatomy-reviewer and design-judge both touch "description" | Accept — anatomy checks presence and format (is it a routing contract syntactically?); design-judge checks tightness and precision (is the routing contract actually tight?). Different angles, same surface. | If agent outputs consistently contradict each other on description quality |
| Stamping (last-reviewed timestamp on artifacts) would make reviewer freshness trackable | Deferred to BACKLOG.md — out of scope for this brainstorm. Reviewer produces verdict only; persistence layer is a separate concern. | When /synapse-gatekeeper needs freshness enforcement |
| fix cycles (max 2) are tracked by dispatcher, not orchestrator | Accept — orchestrator is stateless on lifecycle. Cycle tracking in dispatcher keeps orchestrator reusable across dispatchers with different cycle policies. | If cycle policies need to diverge between synapse-creator and /improve-skill |

---

## 8. Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `synapse/skills/skill/skill-creator/references/skill-anatomy.md` | consumed by `synapse-skill-anatomy-reviewer` | Must exist before anatomy-reviewer is deployed; must be kept current when CLAUDE.md anatomy spec changes |
| `synapse/skills/skill/skill-creator/references/skill-design-principles.md` | consumed by `synapse-skill-design-judge` and `synapse-skill-companion-auditor` | Must exist; currently exists — consumed at runtime |
| `synapse-creator` flow-skill (flow-skill.md `[R]` phase) | dispatches `synapse-skill-signal-reviewer` | Dispatcher must add `[R]` phase block with 2-cycle loop logic |
| `/improve-skill` | dispatches `synapse-skill-signal-reviewer` as structural pre-check | Dispatcher must add pre-check invocation before improvement loop |
| `write-skill-eval` | downstream from reviewer | Receives skill only after APPROVE verdict |
| `synapse-gatekeeper` | re-runs reviewer for promotion freshness | Treated as independent dispatch — orchestrator is stateless |
| `synapse-protocol-signal-reviewer` | pattern precedent (not a dependency) | Relocation to `synapse/agents/synapse/protocol/` is a follow-up task, not a blocker |
