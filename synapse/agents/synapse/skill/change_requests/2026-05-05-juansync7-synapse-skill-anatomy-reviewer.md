# Decision Memo — synapse-skill-anatomy-reviewer

> Artifact type: agent | Memo type: creation | Design doc: `/home/juansync7/ai-synapse/.brainstorms/2026-05-05-synapse-skill-signal-reviewer/notepad.md`

---

## What I want

A binary-gate sub-agent that checks whether a SKILL.md is structurally sound before the skill surfaces to eval generation. It performs fast, deterministic-feeling checks against the canonical skill anatomy spec — returning a per-check PASS/FAIL table and a binary verdict (PASS / FAIL). It does not grade quality (that is `synapse-skill-design-judge`'s job); it gates on presence and correctness of structural anatomy.

---

## Why Claude needs it

Without a structural pre-gate, `write-skill-eval` (and `synapse-creator`'s `[EVAL]` phase) receives SKILL.md files that are missing required frontmatter fields, use the description field as a workflow summary instead of a routing contract, or lack mandatory sections (Wrong-Tool Detection, Progress Tracking). Eval criteria built against malformed anatomy are misaligned to the skill's actual intent — causing false passes or false failures in later review cycles. A fast binary gate before eval gen catches these cheaply.

---

## Injection shape

- **Policy:** Binary-check judgment rules — what counts as a routing contract vs. a workflow summary; when Wrong-Tool Detection is required; when Progress Tracking is required.
- **Domain knowledge:** Skill anatomy spec loaded at runtime from the canonical reference file `synapse/skills/skill/skill-creator/references/skill-anatomy.md` (new file, created as a separate side artifact from this brainstorm). This file consolidates the skill anatomy section from `CLAUDE.md` and the drafting rules from `synapse/skills/synapse/synapse-creator/references/flow-skill.md`. The agent MUST load this file at runtime — do not re-encode anatomy rules inline (drift risk).

---

## What it produces

| Output | Count | Mutable? | Purpose |
|---|---|---|---|
| Per-check PASS/FAIL table | 1 | no | Communicates which anatomy checks passed or failed, with notes |
| Binary verdict (PASS / FAIL) | 1 | no | Gate signal consumed by orchestrator (`synapse-skill-signal-reviewer`) |

---

## Edge cases considered

| Edge case | Handling |
|---|---|
| `status: draft` in frontmatter | Review proceeds regardless — reviewer is stateless on lifecycle. Anatomy must be correct even for drafts. |
| Skill has 0 or 1 phases (Progress Tracking not applicable) | Progress Tracking check is skipped (N/A), not failed. |
| Wrong-Tool Detection not present but skill has `user-invocable: false` | Absence is acceptable — only required when `user-invocable: true` in frontmatter. |
| Spec source file (`skill-anatomy.md`) missing at runtime | Loud-fail: report `SPEC SOURCE MISSING: synapse/skills/skill/skill-creator/references/skill-anatomy.md` and halt — do not proceed with stale or inlined checks. |
| Description field is borderline (contains some routing signal but also workflow detail) | Flag as FAIL with an explicit note — prefer strict interpretation of routing-contract definition. |

---

## Companion files anticipated

**Always-loaded (at invocation):**
- `synapse/skills/skill/skill-creator/references/skill-anatomy.md` — canonical anatomy spec. Loaded first, before any checks run. Agent reads and applies it; never re-encodes inline.

---

## Dependencies

| Artifact | Direction | Contract |
|---|---|---|
| `synapse-skill-signal-reviewer` (orchestrator) | consumes | Receives SKILL.md path from orchestrator, returns PASS/FAIL table + binary verdict |
| `synapse/skills/skill/skill-creator/references/skill-anatomy.md` | consumes | Canonical anatomy spec — must exist at runtime; agent hard-fails if missing |
| `synapse-creator` (flow-skill `[R]` phase) | produces for | Anatomy verdict is one input to the orchestrator's aggregated gate before `[EVAL]` |
| `/improve-skill` | produces for | Used as structural pre-check; anatomy failures reported before design scoring begins |

---

## Checks (verbatim from brainstorm)

All checks are binary (PASS / FAIL). All must pass for a PASS verdict.

| # | Check |
|---|-------|
| 1 | Required frontmatter fields present (`name`, `description`, `domain`, `intent`) |
| 2 | `description` is a routing contract (when-to-fire), not a workflow summary |
| 3 | Mental-model framing paragraph present in body (before mechanics/rules) |
| 4 | Wrong-Tool Detection section present (when `user-invocable: true`) |
| 5 | Progress Tracking section present (when skill has 3+ phases) |
| 6 | MUST / MUST-NOT sections present (if the skill encodes hard constraints) |

---

## Frontmatter

<!-- VERBATIM -->
```yaml
---
name: synapse-skill-anatomy-reviewer
description: "Binary anatomy gate — checks SKILL.md structural anatomy (frontmatter, routing contract, required sections) before eval generation"
domain: synapse
role: reviewer
tags: [anatomy, binary-gate, skill-review, structural]
---
```

---

## Output schema

```markdown
## Anatomy Review — <skill-name>

### Checks
| # | Check | Result | Notes |
|---|-------|--------|-------|
| 1 | Required frontmatter fields | PASS/FAIL | ... |
| 2 | Description is routing contract | PASS/FAIL | ... |
| 3 | Mental-model paragraph present | PASS/FAIL | ... |
| 4 | Wrong-Tool Detection (if applicable) | PASS/N-A/FAIL | ... |
| 5 | Progress Tracking (if 3+ phases) | PASS/N-A/FAIL | ... |
| 6 | MUST/MUST-NOT sections (if applicable) | PASS/N-A/FAIL | ... |

**Verdict:** PASS / FAIL
```

---

## Cross-cutting items (from session)

- **4-segment naming:** `synapse-skill-anatomy-reviewer` follows `domain-subdomain-purpose-role` convention. Confirmed valid.
- **Directory convention (NEW RULE):** Lives at `synapse/agents/synapse/skill/synapse-skill-anatomy-reviewer.md`. The `<domain>/<subdomain>/` directory nesting is a new convention — the inconsistency at `synapse-protocol-signal-reviewer` (old path `synapse/agents/protocol-review/`) is a known follow-up item, not in scope here.
- **Orchestrator parent:** `synapse-skill-signal-reviewer` dispatches this agent in parallel with `synapse-skill-design-judge` and `synapse-skill-companion-auditor`. This agent's PASS/FAIL verdict is the anatomy component of the orchestrator's aggregated result.
- **Spec-source loading rule:** Each sub-agent loads its spec from canonical disk paths — never re-encodes inline. For this agent: `synapse/skills/skill/skill-creator/references/skill-anatomy.md` (new canonical file). Agent loud-fails if the file is missing.
- **Dispatcher chain:** synapse-creator flow-skill `[draft]` → `[R] synapse-skill-signal-reviewer` (which dispatches this sub-agent) → `[EVAL] write-skill-eval`. Also reachable via `/improve-skill` structural pre-check.
- **Model:** sonnet.

---

## Open questions

<!-- empty — all questions resolved -->
