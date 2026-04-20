---
name: synapse-gatekeeper
description: "Use when a skill is complete and ready for promotion review, or to check if a skill meets the bar to land in ai-synapse."
domain: skill.eval
intent: validate
tags: [skill, promotion, certification, gatekeeper]
user-invocable: true
argument-hint: "<skill-path> [--score <0-100>]"
---

Synapse gatekeeper is the promotion gate for ai-synapse. A skill is not ready to merge just because it was built — it must meet the bar. This skill reads a finished skill, checks it across three tiers (structural, quality, registry), and issues a parseable verdict. APPROVE = ready for PR. REVISE = fixable gaps. REJECT = fundamental problem that prevents promotion. The verdict is always the first line so orchestrators can parse it without scanning the full report.

---

## Execution Scope

Ignore any files named `research/`, `EVAL.md`, `PROGRAM.md`, `SCOPE.md`, or `test-inputs/` when they appear in the skill directory being reviewed. These are scaffolding artifacts, not part of the live skill surface. Evaluate only `SKILL.md`, `references/`, `templates/`, and the domain `README.md` row.

---

## Wrong-Tool Detection

| If the user wants to... | Redirect to |
|-------------------------|-------------|
| Fix gaps identified in a verdict | Issue the verdict first, then redirect to `/improve-skill` |
| Build a skill from scratch | `/skill-creator` |
| Review a decision or design approach (not a skill) | `/stakeholder-reviewer` |
| Evaluate or rewrite an EVAL.md only | `/write-skill-eval` |

---

## Progress Tracking

```
TaskCreate "Phase 1 — Load skill files" status:in_progress
TaskCreate "Phase 2 — Structural tier check"
TaskCreate "Phase 3 — Quality tier check"
TaskCreate "Phase 4 — Registry tier check"
TaskCreate "Phase 5 — Issue verdict and report"
```

---

## Inputs

| Input | Required | Description |
|-------|----------|-------------|
| `<skill-path>` | Yes | Path to the skill directory (containing SKILL.md) |
| `--score <0-100>` | No | Eval score from a prior `/improve-skill` or auto-research run |

---

## Phase 1 — Load

Read the following files:
- `<skill-path>/SKILL.md`
- `<skill-path>/EVAL.md`
- `<skill-path>/` directory listing (to detect `references/`, `templates/`, `examples/`)

**Early exits:**
- If `SKILL.md` is absent → emit `VERDICT: REJECT` immediately. Do not proceed.
- If `EVAL.md` is absent → record a REJECT-tier structural failure. Complete the structural checklist (marking EVAL.md as `[ ]`), then issue `VERDICT: REJECT`. Skip Quality and Registry tiers entirely — they require a working eval.

---

## Phase 2 — Structural Tier

> **Read [`../../TAXONOMY.md`](../../TAXONOMY.md)** to validate `domain` and `intent` values against the controlled vocabulary.

| Check | Pass condition |
|-------|---------------|
| SKILL.md exists | File is present and non-empty |
| EVAL.md exists | File is present (**REJECT if absent**) |
| Frontmatter complete | `name`, `description`, `domain`, `intent` all present |
| `domain` in TAXONOMY.md | Value matches a row in TAXONOMY.md |
| `intent` in TAXONOMY.md | Value matches a row in TAXONOMY.md |
| `tags` well-formed | Array of lowercase hyphenated strings |
| `user-invocable` present | Field exists (true or false) |
| `argument-hint` present | Present when `user-invocable: true` |
| Domain README has row | Domain `README.md` contains a row linking this skill |
| Name globally unique | No collision in `SKILLS_REGISTRY.yaml` |

**Name uniqueness:** Check `SKILLS_REGISTRY.yaml` for any entry with the same `name` value. A collision is an immediate REJECT — two skills with the same name cannot coexist in `~/.claude/skills/`.

---

## Phase 3 — Quality Tier

> **Read [`references/skill-design-principles.md`](references/skill-design-principles.md)** before evaluating quality criteria.

| Check | Pass condition |
|-------|---------------|
| Description is routing contract | Specifies *when* the skill fires — not a workflow summary |
| Eval score ≥ 80 | Provided score is ≥ 80 |
| SKILL.md under 500 lines | Line count ≤ 500 |
| Instructions trace to failure modes | Each instruction implies "without this, the agent does X which causes Y" |
| Wrong-Tool Detection present | Section redirects to sibling skills on intent mismatch |
| `references/` used correctly | Companion files load at specific decision points, not inlined wholesale |

**If no score is provided:** Mark the quality tier as `unverified`. A missing score blocks APPROVE — a skill cannot be certified without a measured eval score. The verdict will be at most REVISE.

---

## Phase 4 — Registry Tier

> **Read [`../../SKILLS_REGISTRY.yaml`](../../SKILLS_REGISTRY.yaml)** to check registration status.

A skill is **pipeline-routable** if it: (a) consumes a defined artifact type, (b) produces a defined artifact type, and (c) other skills in the registry depend on its output via `requires_all` or `requires_any`.

| Check | Pass condition |
|-------|---------------|
| Pipeline-routable → has registry entry | `pipeline:` block present with `stage_name`, `input_type`, `output_type`, `context_type`, `requires_all`/`requires_any` |
| Not pipeline-routable → absence is correct | No `pipeline:` block; inventory entry with explanatory comment is sufficient |
| If registered: `stage_name` unique | No other skill uses the same `stage_name` |
| If registered: dependencies resolve | All `requires_all`/`requires_any` values match real stage names in the registry |

---

## Phase 5 — Verdict and Report

> **Read [`../../GOVERNANCE.md`](../../GOVERNANCE.md)** for authoritative REVISE vs. REJECT classification.

**Verdict rules:**

| Condition | Verdict |
|-----------|---------|
| All tiers pass | APPROVE |
| Any fixable gap (score < 80, weak description, missing README row, missing argument-hint, unverified quality tier, missing registry entry for pipeline skill) | REVISE |
| EVAL.md absent, name collision, or fundamental structural failure | REJECT |

> **Read [`examples/example-verdict.md`](examples/example-verdict.md)** for complete worked examples of each verdict type.

**Output format:**

```
VERDICT: <APPROVE | REVISE | REJECT>

## Certification Report — <skill-name>

### Structural                    <✓ | ✗>
- [x] SKILL.md exists
- [x] EVAL.md exists
- [ ] ...

### Quality                       <✓ | ✗ | unverified>
- [x] Description is routing contract
- [ ] ...

### Registry                      <✓ | ✗>
- [x] ...

## Gaps
<specific actionable items — omit section entirely if APPROVE>
```

The verdict must always be the first line of output. Orchestrators rely on this for automated parsing — do not prepend preamble, headers, or explanatory text before it.
