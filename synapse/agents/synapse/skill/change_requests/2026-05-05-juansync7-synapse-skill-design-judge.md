# Decision Memo — synapse-skill-design-judge

> Artifact type: agent | Memo type: creation | Design doc: `.brainstorms/2026-05-05-synapse-skill-signal-reviewer/notepad.md`

---

## What I want

A graded-judgment sub-agent that evaluates design quality of a SKILL.md across six dimensions (scored 1–5). It is dispatched by the `synapse-skill-signal-reviewer` orchestrator alongside two sibling sub-agents. It loads its grading spec at runtime from `synapse/skills/skill/skill-creator/references/skill-design-principles.md` — it does NOT re-encode those principles inline. For every dimension scoring below the fix-suggestion threshold (< 3), it produces a concrete fix suggestion in addition to the score and rationale. Its labeled output format drives orchestrator aggregation.

---

## Why Claude needs it

Without this agent, graded design feedback on a SKILL.md does not exist at creation time. The two existing failure modes are:

1. **Binary reviewers produce false fails.** A skill that leads with a two-sentence mental model paragraph before its mechanics passes a binary "mental-model paragraph present?" check but still fails the design principle if the model paragraph is too thin. Binary cannot catch degree of compliance.
2. **`/improve-skill` is reactive, not proactive.** It runs on an already-generated EVAL.md. By that point, design debt is baked in. The signal-reviewer suite runs before eval generation — it is the gate, not the remediation loop.

Neither the anatomy-reviewer nor the companion-auditor covers this gap: anatomy checks presence/format (binary), companion-auditor checks file hygiene (binary). Design quality is a distinct graded dimension requiring judgment, not detection.

---

## Injection shape

- **Policy:** Grading rubric — judgment rules for each dimension; what constitutes a 1, 3, or 5 on each axis; when to emit a fix suggestion vs. just a score.
- **Domain knowledge:** Six design dimensions loaded at runtime from `skill-design-principles.md` (the canonical source — no inline re-encoding). Fix-suggestion threshold policy (score < 3).

---

## What it produces

| Output | Count | Mutable? | Purpose |
|---|---|---|---|
| Per-dimension score (1–5) | 6 | no | Graded design quality signal per axis |
| Per-dimension rationale | 6 | no | Explains score; enables orchestrator to surface actionable findings |
| Fix suggestion | 0–6 (one per dim < 3) | no | Concrete improvement hint for each failing dimension |
| Labeled output block | 1 | no | `[design] dim-name: N — rationale` format for orchestrator aggregation |

---

## Output schema

<!-- VERBATIM -->
```markdown
### Design Quality (graded 1-5 per dimension)
| Dimension | Score | Notes |
|-----------|-------|-------|
| Mental-model-before-mechanics | 1-5 | ... |
| Policy-over-procedure | 1-5 | ... |
| Failure-mode tracing | 1-5 | ... |
| Loud failure on preconditions | 1-5 | ... |
| No bloat | 1-5 | ... |
| Description tightness | 1-5 | ... |

**Fix suggestions (dimensions scoring < 3):**
- [design] mental-model-before-mechanics: N — <rationale>. Fix: <concrete suggestion>
- [design] policy-over-procedure: N — <rationale>. Fix: <concrete suggestion>
```
<!-- /VERBATIM -->

The `[design] dim-name: N — rationale` label format is required. The orchestrator parses these labels to aggregate findings by source sub-agent.

---

## Frontmatter

<!-- VERBATIM -->
```yaml
---
name: synapse-skill-design-judge
description: "Graded design-quality judge — scores a SKILL.md on six design-principle dimensions (1-5) and emits fix suggestions for dimensions below threshold"
domain: synapse
role: judge
tags: [design-quality, skill-review, graded-judgment]
---
```
<!-- /VERBATIM -->

---

## Grading dimensions

Six dimensions drawn from `skill-design-principles.md` (spec loaded at runtime — not re-encoded here):

| Dimension | What it measures |
|-----------|-----------------|
| mental-model-before-mechanics | Does the skill lead with a conceptual framing paragraph before any rules or procedures? |
| policy-over-procedure | Does the skill teach judgment ("when X, prioritize Y because Z") rather than mechanical steps? |
| failure-mode tracing | Does every instruction trace to a named failure mode it prevents? |
| loud failure on preconditions | Does the skill check inputs and fail clearly, never proceeding silently with bad data? |
| no bloat | Does every token earn its place? No instructions the agent would follow anyway. |
| description tightness | Is the frontmatter `description` a routing contract (when to fire), not a workflow summary? |

---

## Edge cases considered

| Edge case | Handling |
|---|---|
| SKILL.md has no references/ — companion context not available | Agent grades on SKILL.md body only; references/ are optional input for context, not required |
| Dimension scores cluster near threshold (e.g., all 3s) | Agent emits fix suggestions for dims < 3 only; dims at 3 receive rationale only (no suggestion) |
| Skill is in `status: draft` | Agent reviews regardless — reviewer is stateless on lifecycle field |
| Spec source file missing at runtime | Loud fail: emit `AGENT FAILURE: spec source not found at synapse/skills/skill/skill-creator/references/skill-design-principles.md` — do not proceed with inline guesses |
| Dimension is genuinely not applicable (e.g., no preconditions possible) | Score 5 with rationale: "N/A — no preconditions; dimension vacuously satisfied." Do not penalize. |

---

## Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `synapse-skill-signal-reviewer` (orchestrator) | consumes this agent | Dispatches with path to SKILL.md (+ optional references/ path); aggregates labeled `[design]` output |
| `synapse/skills/skill/skill-creator/references/skill-design-principles.md` | consumes (loads at runtime) | Canonical grading spec. Load once at start; never re-encode inline |
| `synapse-skill-anatomy-reviewer` (sibling) | independent parallel dispatch | No contract — results are aggregated independently by orchestrator |
| `synapse-skill-companion-auditor` (sibling) | independent parallel dispatch | No contract — results are aggregated independently by orchestrator |
| `synapse-creator` flow-skill `[R]` phase | dispatches via orchestrator | Orchestrator is the dispatcher; this agent does not interact with flow-skill directly |
| `/improve-skill` | dispatches via orchestrator | Orchestrator is the dispatcher; this agent does not interact with improve-skill directly |

---

## Canonical location

`synapse/agents/synapse/skill/synapse-skill-design-judge.md`

**Model:** sonnet

---

## Open questions

<!-- empty — all questions resolved -->
